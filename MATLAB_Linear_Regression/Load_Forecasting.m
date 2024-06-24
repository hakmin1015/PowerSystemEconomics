% 선형회귀 분석을 사용한 전력 수요 예측 프로젝트
% 3조 : 이학민, 박태현, 이혜정

close all; clear; clc;

format short;

% 외부 데이터를 불러와 변수에 저장함.
power_file = 'OPENAPI_Power_Jeju(2021.01-2023.12).xlsx';
ptemp_file = 'ptemp_day.xlsx';
solar_file = 'solar_24times.xlsx';
solar_corr_file = '24hours_solar_correlation.xlsx';
solar_day_file = 'solar_day.xlsx';

raw_power = readmatrix(power_file);     
raw_ptemp = readmatrix(ptemp_file);
raw_solar = readmatrix(solar_file);
raw_solar_corr = readmatrix(solar_corr_file);
raw_solar_day = readmatrix(solar_day_file);

% P.U. data를 생성함.
max_min_power = zeros(1095,3);
pu_power = zeros(1095,25);
max_min_power(:,1) = raw_power(:,1);
for i = 1:1095
    max_min_power(i,2) = max(raw_power(i,2:25));
    max_min_power(i,3) = min(raw_power(i,2:25));
end
pu_power(:,1) = raw_power(:,1);
pu_power(:,2:end) = (raw_power(:,2:25) - max_min_power(:,3)) ./ (max_min_power(:,2) - max_min_power(:,3));

% 연도 별 가중치를 적용함.
edited_power = zeros(1095,24);

avg_2021 = zeros(1,24);
avg_2022 = zeros(1,24);
avg_2023 = zeros(1,24);

for i = 1:1095
    if floor(raw_power(i,1)/10000) == 2021
        avg_2021 = avg_2021 + raw_power(i,2:25);

    elseif floor(raw_power(i,1)/10000) == 2022
        avg_2022 = avg_2022 + raw_power(i,2:25);

    else
        avg_2023 = avg_2023 + raw_power(i,2:25);
    end
end

avg_2021 = avg_2021 / 365;
avg_2022 = avg_2022 / 365;
avg_2023 = avg_2023 / 365;

w_2021 = avg_2023 ./ avg_2021;
w_2022 = avg_2023 ./ avg_2022;

for i = 1:1095
    if floor(raw_power(i,1)/10000) == 2021
        edited_power(i,1) = raw_power(i,1);
        edited_power(i,2:25) = raw_power(i,2:25) .* w_2021;

    elseif floor(raw_power(i,1)/10000) == 2022
        edited_power(i,1) = raw_power(i,1);
        edited_power(i,2:25) = raw_power(i,2:25) .* w_2022;

    else
        edited_power(i,1) = raw_power(i,1);
        edited_power(i,2:25) = raw_power(i,2:25);
    end
end

% 오차율 저장을 위한 변수 선언
cnt1 = 1; cnt2 = 1; cnt3 = 1; cnt4 = 1; cnt5 = 1; cnt6 = 1; cnt7 = 1; cnt8 = 1; cnt9 = 1;

% 전체
total_abs_max_errs = zeros(1,365);
total_abs_min_errs = zeros(1,365);
total_max_errs = zeros(1,365);
total_min_errs = zeros(1,365);
total_max_time_errs = zeros(1,365);
total_min_time_errs = zeros(1,365);

% 봄
spring_abs_max_errs = zeros(1,92);
spring_abs_min_errs = zeros(1,92);
spring_max_errs = zeros(1,92);
spring_min_errs = zeros(1,92);
spring_max_time_errs = zeros(1,92);
spring_min_time_errs = zeros(1,92);

% 여름
summer_abs_max_errs = zeros(1,92);
summer_abs_min_errs = zeros(1,92);
summer_max_errs = zeros(1,92);
summer_min_errs = zeros(1,92);
summer_max_time_errs = zeros(1,92);
summer_min_time_errs = zeros(1,92);

% 가을
autumn_abs_max_errs = zeros(1,91);
autumn_abs_min_errs = zeros(1,91);
autumn_max_errs = zeros(1,91);
autumn_min_errs = zeros(1,91);
autumn_max_time_errs = zeros(1,91);
autumn_min_time_errs = zeros(1,91);

% 겨울
winter_abs_max_errs = zeros(1,90);
winter_abs_min_errs = zeros(1,90);
winter_max_errs = zeros(1,90);
winter_min_errs = zeros(1,90);
winter_max_time_errs = zeros(1,90);
winter_min_time_errs = zeros(1,90);

% 평일
weekday_abs_max_errs = zeros(1,248);
weekday_abs_min_errs = zeros(1,248);
weekday_max_errs = zeros(1,248);
weekday_min_errs = zeros(1,248);
weekday_max_time_errs = zeros(1,248);
weekday_min_time_errs = zeros(1,248);

% 주말
weekend_abs_max_errs = zeros(1,100);
weekend_abs_min_errs = zeros(1,100);
weekend_max_errs = zeros(1,100);
weekend_min_errs = zeros(1,100);
weekend_max_time_errs = zeros(1,100);
weekend_min_time_errs = zeros(1,100);

% 특수일
holiday_abs_max_errs = zeros(1,17);
holiday_abs_min_errs = zeros(1,17);
holiday_max_errs = zeros(1,17);
holiday_min_errs = zeros(1,17);
holiday_max_time_errs = zeros(1,17);
holiday_min_time_errs = zeros(1,17);

% 가장 처음 데이터의 날짜(2021-01-01)를 계산하여 base_date 변수에 저장함.
[~,~,~,base_date] = make_date(raw_power(1,1));

% 2023-01-01 ~ 2023-12-31의 전력 수요를 예측함.
start_date = datetime(2023,1,1);
end_date = datetime(2023,12,31);

for pred_date = start_date : end_date
    
    % date = input('Input Date for Load Forecasting(YYYYMMDD) : '); % 20230101 ~ 20231231
    % date = 20230507;
    
    % predict day
    % [p_year,p_month,p_day,pred_date] = make_date(date);

    % 예측하는 날짜 생성
    [p_year, p_month, p_day] = ymd(pred_date);
    DateNum = days(pred_date-base_date) + 1;

    % 예측하는 날의 실제 정보 저장
    truth_power = raw_power(DateNum,1:end-1);
    truth_ptemp = raw_ptemp(DateNum,1:end-1);
    truth_solar = raw_solar(DateNum,1:end);
    truth_solar_day = raw_solar_day(DateNum,1:end-1);
    
    % 예측일의 실제 최대, 최소 수요량과 발생 시간 저장
    truth_max_power = max(truth_power(2:25));
    truth_max_time = find(truth_power(2:25) == truth_max_power,1,"first");
    truth_min_power = min(truth_power(2:25));
    truth_min_time = find(truth_power(2:25) == truth_min_power,1,"first");
    
    % 사용 가능한 데이터 (예측일로부터 2일 전까지)
    use_power = edited_power(1:DateNum-2,:);
    use_pu_power = pu_power(1:DateNum-2,:);
    use_ptemp = raw_ptemp(1:DateNum-2,:);
    use_solar = raw_solar(1:DateNum-2,:);
    
    % 예측 시점 기준 하루 전 날 데이터 추출
    power_before_1day = use_power(end,2:end);
    pu_power_before_1day = use_pu_power(end,2:end);
    ptemp_before_1day = use_ptemp(end,2);
    solar_before_1day = use_solar(end,2:end);
    use_power(end,:) = [];
    use_pu_power(end,:) = [];
    use_ptemp(end,:) = [];
    use_solar(end,:) = [];

    [SIZE,~] = size(use_power);

    filtered_power = zeros(SIZE,25);
    filtered_pu_power = zeros(SIZE,25);
    filtered_ptemp = zeros(SIZE,7);
    filtered_solar = zeros(SIZE,25);
    sol_corr_monthly = zeros(1,25);

    % Month Filter          * 광범위한 계절보다는 월 별로 구분하는 것이 더 결과값이 좋을 것이라 예상함.
    [filtered_power,filtered_pu_power,filtered_ptemp,filtered_solar,tmp_power,tmp_pu_power,tmp_ptemp,tmp_solar,sol_corr_monthly,SIZE] ...
            = month_filter(SIZE,truth_ptemp,use_power,use_pu_power,use_ptemp,use_solar,raw_solar_corr,filtered_power,filtered_pu_power,filtered_ptemp,filtered_solar,sol_corr_monthly);
    
    % Week Filter           * 평일/(주말+특수일)로 구분함.
    [filtered_power,filtered_pu_power,filtered_ptemp,filtered_solar,tmp_power,tmp_pu_power,tmp_ptemp,tmp_solar,SIZE] ...
            = week_filter(SIZE,truth_ptemp,tmp_power,tmp_pu_power,tmp_ptemp,tmp_solar,filtered_power,filtered_pu_power,filtered_ptemp,filtered_solar);

    % 덕커브 생성
    duck_curve = mean(filtered_pu_power(:,2:end),1);

    % 선형회귀 분석
    ptemps = filtered_ptemp(:,2);
    ptemps_avg = mean(ptemps);
    solar_avg_24 = mean(filtered_solar(:,2:end),1);
    diff_solar = zeros(1,24);

    % 체감온도에 따른 전력량 선형회귀 모델 생성
    pred_max_model = polyfit(ptemps, max(filtered_power(:,2:end),[],2),1);
    pred_min_model = polyfit(ptemps, min(filtered_power(:,2:end),[],2),1);

    % 선형회귀 전력량 예측 수행
    pred_max_power = polyval(pred_max_model, truth_ptemp(2));
    pred_min_power = polyval(pred_min_model, truth_ptemp(2));

    % 예측 시점 하루 전 날의 데이터(예측일과 가장 가까운 날짜) 반영
    if mod(truth_ptemp(6),2) == 0 && abs(truth_ptemp(2)-ptemp_before_1day) < 1      % 예측하는 날과 예측 시점 기준 하루 전 날의 유형(평일/휴일)이 다른 경우 하루 전 날의 가중치를 작게 함.
        alpha = 0.7;
    elseif mod(truth_ptemp(6),2) == 0 && abs(truth_ptemp(2)-ptemp_before_1day) < 5      % 날짜 유형은 같으나 체감 온도 차이가 5도 이상 날 때
        alpha = 0.3;
    else    % 체감온도 차이가 많이 나고 날짜 유형도 다를 때
        alpha = 0.01;
    end
    pred_max_power = (alpha * max(power_before_1day)) + ((1-alpha) * pred_max_power);
    pred_min_power = (alpha * min(power_before_1day)) + ((1-alpha) * pred_min_power);
    ptemps_avg = (alpha * ptemp_before_1day) + ((1-alpha) * ptemps_avg);
    solar_avg_24 = (alpha * solar_before_1day) + ((1-alpha) * solar_avg_24);
    duck_curve = (alpha * duck_curve) + ((1-alpha) * duck_curve);

    % 덕커브를 통한 24시간 전력 수요 예측
    pred_power = duck_curve * (pred_max_power - pred_min_power) + pred_min_power;

    % 월별 일사량 반영 (월마다의 전력량 보정값은 2022년 데이터 분석에 의해 정해짐.)
    switch truth_power(27)
        case 1
            if max(truth_solar(2:end)) >= 1.01
                power_correction = 110;
            else
                power_correction = 0;
            end

        case 2
            if max(truth_solar(2:end)) >= 1.6
                power_correction = 90;
            else
                power_correction = 0;
            end

        case 3
            if max(truth_solar(2:end)) >= 2.0
                power_correction = 111;
            else
                power_correction = 0;
            end

        case 4
            if max(truth_solar(2:end)) >= 2.0
                power_correction = 85;
            else
                power_correction = 0;
            end

        case 5
            if max(truth_solar(2:end)) >= 2.9
                power_correction = 70;
            else
                power_correction = 0;
            end

        case 9
            if max(truth_solar(2:end)) >= 1.98
                power_correction = 14;
            else
                power_correction = 0;
            end

        case 11
            if max(truth_solar(2:end)) >= 1.1
                power_correction = 70;
            else
                power_correction = 0;
            end

        case 12
            if max(truth_solar(2:end)) >= 0.7
                power_correction = 49;
            else
                power_correction = 0;
            end

        otherwise
            power_correction = 0;
    end

    for i = 1:24
        if truth_solar(i+1) ~= 0 && sol_corr_monthly(i+1) < 0
             pred_power(i) = pred_power(i) + sol_corr_monthly(i+1) * power_correction;
        end
    end

    % 계산된 최대 최소 전력량과 발생 시간을 변수에 저장함.
    pred_max_power = max(pred_power);
    pred_max_time = find(pred_power == pred_max_power,1,"first");
    pred_min_power = min(pred_power);
    pred_min_time = find(pred_power == pred_min_power,1,"first");
    max_err = ((pred_max_power-truth_max_power)/truth_max_power)*100;
    min_err = ((pred_min_power-truth_min_power)/truth_min_power)*100;
    abs_max_err = abs(((pred_max_power-truth_max_power)/truth_max_power))*100;
    abs_min_err = abs((pred_min_power-truth_min_power)/truth_min_power)*100;
    max_time_err = abs(pred_max_time - truth_max_time);
    min_time_err = abs(pred_min_time - truth_min_time);

    % 오차율을 저장함.
    total_abs_max_errs(1,cnt1) = abs_max_err;
    total_abs_min_errs(1,cnt1) = abs_min_err;
    total_max_errs(1,cnt1) = max_err;
    total_min_errs(1,cnt1) = min_err;
    total_max_time_errs(1,cnt1) = max_time_err;
    total_min_time_errs(1,cnt1) = min_time_err;
    cnt1 = cnt1 + 1;

    switch truth_power(26)      % 계절별 오차율 (봄, 여름, 가을, 겨울)
        case 1
            spring_abs_max_errs(1,cnt2) = abs_max_err;
            spring_abs_min_errs(1,cnt2) = abs_min_err;
            spring_max_errs(1,cnt2) = max_err;
            spring_min_errs(1,cnt2) = min_err;
            spring_max_time_errs(1,cnt2) = max_time_err;
            spring_min_time_errs(1,cnt2) = min_time_err;
            cnt2 = cnt2 + 1;

        case 2
            summer_abs_max_errs(1,cnt3) = abs_max_err;
            summer_abs_min_errs(1,cnt3) = abs_min_err;
            summer_max_errs(1,cnt3) = max_err;
            summer_min_errs(1,cnt3) = min_err;
            summer_max_time_errs(1,cnt3) = max_time_err;
            summer_min_time_errs(1,cnt3) = min_time_err;
            cnt3 = cnt3 + 1;

        case 3
            autumn_abs_max_errs(1,cnt4) = abs_max_err;
            autumn_abs_min_errs(1,cnt4) = abs_min_err;
            autumn_max_errs(1,cnt4) = max_err;
            autumn_min_errs(1,cnt4) = min_err;
            autumn_max_time_errs(1,cnt4) = max_time_err;
            autumn_min_time_errs(1,cnt4) = min_time_err;
            cnt4 = cnt4 + 1;

        case 4
            winter_abs_max_errs(1,cnt5) = abs_max_err;
            winter_abs_min_errs(1,cnt5) = abs_min_err;
            winter_max_errs(1,cnt5) = max_err;
            winter_min_errs(1,cnt5) = min_err;
            winter_max_time_errs(1,cnt5) = max_time_err;
            winter_min_time_errs(1,cnt5) = min_time_err;
            cnt5 = cnt5 + 1;
    end

    switch truth_power(28)      % 날짜 유형별 오차율 (평일, 주말, 특수일)
        case 1
            weekday_abs_max_errs(1,cnt6) = abs_max_err;
            weekday_abs_min_errs(1,cnt6) = abs_min_err;
            weekday_max_errs(1,cnt6) = max_err;
            weekday_min_errs(1,cnt6) = min_err;
            weekday_max_time_errs(1,cnt6) = max_time_err;
            weekday_min_time_errs(1,cnt6) = min_time_err;
            cnt6 = cnt6 + 1;

        case 2
            weekday_abs_max_errs(1,cnt6) = abs_max_err;
            weekday_abs_min_errs(1,cnt6) = abs_min_err;
            weekday_max_errs(1,cnt6) = max_err;
            weekday_min_errs(1,cnt6) = min_err;
            weekday_max_time_errs(1,cnt6) = max_time_err;
            weekday_min_time_errs(1,cnt6) = min_time_err;
            cnt6 = cnt6 + 1;

        case 3
            weekend_abs_max_errs(1,cnt7) = abs_max_err;
            weekend_abs_min_errs(1,cnt7) = abs_min_err;
            weekend_max_errs(1,cnt7) = max_err;
            weekend_min_errs(1,cnt7) = min_err;
            weekend_max_time_errs(1,cnt7) = max_time_err;
            weekend_min_time_errs(1,cnt7) = min_time_err;
            cnt7 = cnt7 + 1;

        case 4
            weekend_abs_max_errs(1,cnt7) = abs_max_err;
            weekend_abs_min_errs(1,cnt7) = abs_min_err;
            weekend_max_errs(1,cnt7) = max_err;
            weekend_min_errs(1,cnt7) = min_err;
            weekend_max_time_errs(1,cnt7) = max_time_err;
            weekend_min_time_errs(1,cnt7) = min_time_err; 
            cnt7 = cnt7 + 1;

        case 5
            holiday_abs_max_errs(1,cnt8) = abs_max_err;
            holiday_abs_min_errs(1,cnt8) = abs_min_err;
            holiday_max_errs(1,cnt8) = max_err;
            holiday_min_errs(1,cnt8) = min_err;
            holiday_max_time_errs(1,cnt8) = max_time_err;
            holiday_min_time_errs(1,cnt8) = min_time_err;
            cnt8 = cnt8 + 1;

        case 6
            holiday_abs_max_errs(1,cnt8) = abs_max_err;
            holiday_abs_min_errs(1,cnt8) = abs_min_err;
            holiday_max_errs(1,cnt8) = max_err;
            holiday_min_errs(1,cnt8) = min_err;
            holiday_max_time_errs(1,cnt8) = max_time_err;
            holiday_min_time_errs(1,cnt8) = min_time_err;
            cnt8 = cnt8 + 1;
    end

    % 예측 결과를 화면에 출력함.
    fprintf("\n<Truth Data of [%d/%d/%d]>\n",p_year,p_month,p_day);
    fprintf("Max : %d[MW](%d시)\nMin : %d[MW](%d시)",...
            round(truth_max_power), truth_max_time, round(truth_min_power), truth_min_time);

    fprintf("\n<Predict Data of [%d/%d/%d]>\n",p_year,p_month,p_day);
    fprintf("Max : %d[MW](%d시)\nMin : %d[MW](%d시)",...
            round(pred_max_power), pred_max_time, round(pred_min_power), pred_min_time);

    fprintf("\n<Load Forecasting Error of [%d/%d/%d]>\n",p_year,p_month,p_day);
    fprintf("Max : 오차율 %.2f[%%], 시간 차이 %d[hr]\nMin : 오차율 %.2f[%%], 시간 차이 %d[hr]\n",...
            max_err, pred_max_time-truth_max_time, min_err, pred_min_time-truth_min_time);
end

% 전체 오차
fprintf('\n\n<전체>\n');
fprintf('max 평균 오차 : %.3f[%%]\n', mean(total_abs_max_errs));
fprintf('min 평균 오차 : %.3f[%%]\n', mean(total_abs_min_errs));

fprintf('max 오차 분산 : %.3f\n', var(total_abs_max_errs));
fprintf('min 오차 분산 : %.3f\n', var(total_abs_min_errs));

fprintf('max 발생 시간 오차 : %.1f[시간]\n', mean(total_max_time_errs));
fprintf('min 발생 시간 오차 : %.1f[시간]\n', mean(total_min_time_errs));

% 봄 오차
fprintf('\n\n<봄>\n');
fprintf('max 평균 오차 : %.3f[%%]\n', mean(spring_abs_max_errs));
fprintf('min 평균 오차 : %.3f[%%]\n', mean(spring_abs_min_errs));

fprintf('max 오차 분산 : %.3f\n', var(spring_abs_max_errs));
fprintf('min 오차 분산 : %.3f\n', var(spring_abs_min_errs));

fprintf('max 발생 시간 오차 : %.1f[시간]\n', mean(spring_max_time_errs));
fprintf('min 발생 시간 오차 : %.1f[시간]\n', mean(spring_min_time_errs));

% 여름 오차
fprintf('\n\n<여름>\n');
fprintf('max 평균 오차 : %.3f[%%]\n', mean(summer_abs_max_errs));
fprintf('min 평균 오차 : %.3f[%%]\n', mean(summer_abs_min_errs));

fprintf('max 오차 분산 : %.3f\n', var(summer_abs_max_errs));
fprintf('min 오차 분산 : %.3f\n', var(summer_abs_min_errs));

fprintf('max 발생 시간 오차 : %.1f[시간]\n', mean(summer_max_time_errs));
fprintf('min 발생 시간 오차 : %.1f[시간]\n', mean(summer_min_time_errs));

% 가을 오차
fprintf('\n\n<가을>\n');
fprintf('max 평균 오차 : %.3f[%%]\n', mean(autumn_abs_max_errs));
fprintf('min 평균 오차 : %.3f[%%]\n', mean(autumn_abs_min_errs));

fprintf('max 오차 분산 : %.3f\n', var(autumn_abs_max_errs));
fprintf('min 오차 분산 : %.3f\n', var(autumn_abs_min_errs));

fprintf('max 발생 시간 오차 : %.1f[시간]\n', mean(autumn_max_time_errs));
fprintf('min 발생 시간 오차 : %.1f[시간]\n', mean(autumn_min_time_errs));

% 겨울 오차
fprintf('\n\n<겨울>\n');
fprintf('max 평균 오차 : %.3f[%%]\n', mean(winter_abs_max_errs));
fprintf('min 평균 오차 : %.3f[%%]\n', mean(winter_abs_min_errs));

fprintf('max 오차 분산 : %.3f\n', var(winter_abs_max_errs));
fprintf('min 오차 분산 : %.3f\n', var(winter_abs_min_errs));

fprintf('max 발생 시간 오차 : %.1f[시간]\n', mean(winter_max_time_errs));
fprintf('min 발생 시간 오차 : %.1f[시간]\n', mean(winter_min_time_errs));

% 평일 오차
fprintf('\n\n<평일>\n');
fprintf('max 평균 오차 : %.3f[%%]\n', mean(weekday_abs_max_errs));
fprintf('min 평균 오차 : %.3f[%%]\n', mean(weekday_abs_min_errs));

fprintf('max 오차 분산 : %.3f\n', var(weekday_abs_max_errs));
fprintf('min 오차 분산 : %.3f\n', var(weekday_abs_min_errs));

fprintf('max 발생 시간 오차 : %.1f[시간]\n', mean(weekday_max_time_errs));
fprintf('min 발생 시간 오차 : %.1f[시간]\n', mean(weekday_min_time_errs));

% 주말 오차
fprintf('\n\n<주말>\n');
fprintf('max 평균 오차 : %.3f[%%]\n', mean(weekend_abs_max_errs));
fprintf('min 평균 오차 : %.3f[%%]\n', mean(weekend_abs_min_errs));

fprintf('max 오차 분산 : %.3f\n', var(weekend_abs_max_errs));
fprintf('min 오차 분산 : %.3f\n', var(weekend_abs_min_errs));

fprintf('max 발생 시간 오차 : %.1f[시간]\n', mean(weekend_max_time_errs));
fprintf('min 발생 시간 오차 : %.1f[시간]\n', mean(weekend_min_time_errs));

% 특수일 오차
fprintf('\n\n<특수일>\n');
fprintf('max 평균 오차 : %.3f[%%]\n', mean(holiday_abs_max_errs));
fprintf('min 평균 오차 : %.3f[%%]\n', mean(holiday_abs_min_errs));

fprintf('max 오차 분산 : %.3f\n', var(holiday_abs_max_errs));
fprintf('min 오차 분산 : %.3f\n', var(holiday_abs_min_errs));

fprintf('max 발생 시간 오차 : %.1f[시간]\n', mean(holiday_max_time_errs));
fprintf('min 발생 시간 오차 : %.1f[시간]\n', mean(holiday_min_time_errs));