def solution(board, skill):
    n = len(board)
    m = len(board[0])
    dp = [[0]*(m+1) for _ in range(n+1)]
    
    for type_s, r1,c1,r2,c2,degree in skill:
        if type_s ==1:
            degree = -degree
        
        dp[r1][c1] += degree
        dp[r1][c2+1] -= degree
        dp[r2+1][c1] -= degree
        dp[r2+1][c2+1] += degree
        
    for i in range(n+1):
        for j in range(1,m+1):
            dp[i][j] += dp[i][j-1]
        
    for j in range(m+1):
        for i in range(1,n+1):
            dp[i][j] += dp[i-1][j]
                
    result=0
    for i in range(n):
        for j in range(m):
            if board[i][j] + dp[i][j] >0:
                result += 1
    return result