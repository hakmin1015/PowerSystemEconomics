function [filtered_power,filtered_pu_power,filtered_ptemp,filtered_solar,tmp_power,tmp_pu_power,tmp_ptemp,tmp_solar,sol_corr_monthly,SIZE] ...
            = month_filter(SIZE,truth_ptemp,use_power,use_pu_power,use_ptemp,use_solar,raw_solar_corr,filtered_power,filtered_pu_power,filtered_ptemp,filtered_solar,sol_corr_monthly)

    % 예측일과 같은 달만 남도록 필터링 함.
    j = 1;
    for i = 1:SIZE
        if truth_ptemp(1,4) == use_ptemp(i,4)
            filtered_power(j,:) = use_power(i,:);
            filtered_pu_power(j,:) = use_pu_power(i,:);
            filtered_ptemp(j,:) = use_ptemp(i,:);
            filtered_solar(j,:) = use_solar(i,:);
            j = j+1;
        end
    end

    % 월에 따른 일사량 상관계수를 필터링 함.
    for i = 1:12
        if truth_ptemp(1,4) == raw_solar_corr(i,1)
            sol_corr_monthly = raw_solar_corr(i,:);
        end
    end

    % Filter Reset
    [filtered_power,filtered_pu_power,filtered_ptemp,filtered_solar,tmp_power,tmp_pu_power,tmp_ptemp,tmp_solar,SIZE] ...
         = reset_filter(filtered_power,filtered_pu_power,filtered_ptemp,filtered_solar,j);

end