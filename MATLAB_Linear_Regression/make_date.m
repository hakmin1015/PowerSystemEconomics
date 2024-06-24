function [year,month,day,output_date] = make_date(input_date)

    year = floor(input_date/10000);
    month = floor((input_date-10000*year) / 100);
    day = mod(input_date, 100);
    
    output_date = datetime(year,month,day);
end