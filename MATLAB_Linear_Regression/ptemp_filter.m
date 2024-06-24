function [filtered_power,filtered_pu_power,filtered_ptemp,filtered_solar,tmp_power,tmp_pu_power,tmp_ptemp,tmp_solar,sol_corr_monthly,SIZE] = ...
            ptemp_filter(truth_ptemp,use_power,use_pu_power,use_ptemp,use_solar,filtered_power,filtered_pu_power,filtered_ptemp,filtered_solar,sol_corr_monthly,N)
    
    diff_ptemp = abs(use_ptemp(:,2) - truth_ptemp(1,2));
    
    % 체감온도의 차이를 내림차순으로 정렬함.
    [~, idx] = sort(transpose(diff_ptemp), 'descend');
    
    % 상위 N개의 인덱스를 추출
    top_idx = idx(1:N);
    j = N+1;
    SIZE = N;

    filtered_power(1:N,:) = use_power(top_idx,:);
    filtered_pu_power(1:N,:) = use_pu_power(top_idx,:);
    filtered_ptemp(1:N,:) = use_ptemp(top_idx,:);
    filtered_solar(1:N,:) = use_solar(top_idx,:);
    
    % Filter Reset
    [filtered_power,filtered_pu_power,filtered_ptemp,filtered_solar,tmp_power,tmp_pu_power,tmp_ptemp,tmp_solar,SIZE] ...
            = reset_filter(filtered_power,filtered_pu_power,filtered_ptemp,filtered_solar,j);

end