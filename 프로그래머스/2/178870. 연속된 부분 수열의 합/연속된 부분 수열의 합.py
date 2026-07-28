def solution(sequence, k):
    n = len(sequence)
    answer = [0,n-1,n]
    left = 0
    right = 0
    length = 0
    
    sum_val = sequence[0]
    
    while left < n:
        if sum_val == k:
            length = right-left
            if length < answer[2]:
                answer = [left,right,length]
        
        if right <n-1 and sum_val < k:
            right += 1
            sum_val += sequence[right]
            
        else:
            sum_val -= sequence[left]
            left += 1
    return answer[0:2]