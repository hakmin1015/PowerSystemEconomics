function [filtered_power,filtered_pu_power,filtered_ptemp,filtered_solar,tmp_power,tmp_pu_power,tmp_ptemp,tmp_solar,SIZE] ...
            = week_filter(SIZE,truth_ptemp,use_power,use_pu_power,use_ptemp,use_solar,filtered_power,filtered_pu_power,filtered_ptemp,filtered_solar)

    % 예측일과 같은 종류의 날(평일/주말+특수일)만 남도록 필터링 함.
    % 1 : 하루 전 날이 휴일인 '평일'
    % 2 : 하루 전 날이 평일인 '평일'
    % 3 : 하루 전 날이 평일인 '주말'
    % 4 : 하루 전 날이 휴일인 '주말'
    % 5 : 하루 전 날이 평일인 '특수일'
    % 6 : 하루 전 날이 휴일인 '특수일'

    j = 1;
    for i = 1:SIZE
        if truth_ptemp(1,5) == 1 || truth_ptemp(1,5) == 2   % 예측일이 평일인 경우 평일 데이터만 남김.
            if use_ptemp(i,5) == 1 || use_ptemp(i,5) == 2
                filtered_power(j,:) = use_power(i,:);
                filtered_pu_power(j,:) = use_pu_power(i,:);
                filtered_ptemp(j,:) = use_ptemp(i,:);
                filtered_solar(j,:) = use_solar(i,:);
                j = j+1;
            end

        else        % 예측일이 주말 또는 특수일인 경우만 남김.
            if use_ptemp(i,5) == 3 || use_ptemp(i,5) == 4 || use_ptemp(i,5) == 5 || use_ptemp(i,5) == 6
                filtered_power(j,:) = use_power(i,:);
                filtered_pu_power(j,:) = use_pu_power(i,:);
                filtered_ptemp(j,:) = use_ptemp(i,:);
                filtered_solar(j,:) = use_solar(i,:);
                j = j+1;
            end
        end
    end
    
    % Filter Reset
    [filtered_power,filtered_pu_power,filtered_ptemp,filtered_solar,tmp_power,tmp_pu_power,tmp_ptemp,tmp_solar,SIZE] ...
            = reset_filter(filtered_power,filtered_pu_power,filtered_ptemp,filtered_solar,j);

end