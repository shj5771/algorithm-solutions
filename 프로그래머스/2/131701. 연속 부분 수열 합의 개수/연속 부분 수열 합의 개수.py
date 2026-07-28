def solution(elements):
    n = len(elements)
    sum_list = []
    ex_list = elements + elements
    result = []
    for length in range(1,n+1):
        current_sum = sum(elements[:length])
        result.append(current_sum)
        for k in range(0,n-1):
            current_sum = current_sum - ex_list[k] + ex_list[k+length]
            result.append(current_sum)
       
    result = set(result)
    return len(result)
        
            
            