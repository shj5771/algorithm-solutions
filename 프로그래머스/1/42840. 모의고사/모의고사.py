def solution(answers):
    one_value = [1,2,3,4,5] * 10000
    two_value = [2,1,2,3,2,4,2,5] * 10000
    three_value = [3,3,1,1,2,2,4,4,5,5] * 10000
    
    count_val = [0] * 3
    max_val = 0
    for k in range(len(answers)):
        if answers[k] == one_value[k]:
            count_val[0] += 1
        if answers[k] == two_value[k]:
            count_val[1] += 1
        if answers[k] == three_value[k]:
            count_val[2] += 1
    
    for i in range(3):
        if count_val[i] >= max_val:
            max_val = count_val[i]
    
    result=[]
    for j in range(3):
        if max_val == count_val[j]:
            result.append(j+1)
    
    return result