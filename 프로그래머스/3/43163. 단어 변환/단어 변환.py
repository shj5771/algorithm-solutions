from collections import deque
queue = deque()

def solution(begin, target, words):
    
    n = len(begin)
    count_val = 0
    visited = [False] * (len(words))
    queue.append((begin,0))
    
    while queue:
        now_word,count_val = queue.popleft()
        
        if now_word == target:
            return count_val
        
        for k in range(len(words)):
            same_count=0
            for j in range(n):
                if now_word[j] == words[k][j]:                
                    same_count += 1
            
            if same_count ==n-1 and visited[k] == False:
                visited[k] = True
                queue.append((words[k],count_val +1))
                
    
    return 0