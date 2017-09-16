# @param {Integer[]} time_series
# @param {Integer} duration
# @return {Integer}
def find_poisoned_duration(time_series, duration)
    return 0 if time_series.empty?
        
    total_time = 0
    1.upto(time_series.length - 1) do |n|
        timediff = time_series[n] - time_series[n - 1]
        if timediff > duration
            total_time += duration
        else
            total_time += timediff
        end
    end
    total_time += duration
end
