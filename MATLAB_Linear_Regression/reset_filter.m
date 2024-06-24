function [filtered_power,filtered_pu_power,filtered_ptemp,filtered_solar,tmp_power,tmp_pu_power,tmp_ptemp,tmp_solar,SIZE] ...
            = reset_filter(filtered_power,filtered_pu_power,filtered_ptemp,filtered_solar,j)
    
    filtered_power(j:end,:) = [];
    filtered_pu_power(j:end,:) = [];
    filtered_ptemp(j:end,:) = [];
    filtered_solar(j:end,:) = [];

    tmp_power = filtered_power;
    tmp_pu_power = filtered_pu_power;
    tmp_ptemp = filtered_ptemp;
    tmp_solar = filtered_solar;
    
    SIZE = j-1;
end