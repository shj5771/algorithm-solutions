def solution(begin, target, words):
    n = len(words)
    m = len(words[0])
    min_val= float("inf")
    visited = [False]*n
    
    def dfs(now_word,target,num):
        nonlocal min_val
        if now_word == target:
            if num<min_val:
                min_val = num
    
        for i in range(n):
            if visited[i]:
                continue
                
            unit_sum = 0
            for j in range(m):
                if words[i][j] == now_word[j]:
                    unit_sum += 1
        
            if unit_sum == m-1:
                visited[i] = True
                dfs(words[i],target,num+1)
                visited[i] = False
    dfs(begin,target,0)
    return min_val if min_val != float("inf") else 0