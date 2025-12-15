#!/usr/bin/env python3
import sys

hostname = sys.argv[1]

def fibonacci(n):
    seq = [0, 1]
    for _ in range(2, n):
        seq.append(seq[-1] + seq[-2])
    return seq[:n]

def primes(n):
    if n < 2:
        return []
    result = [2]
    for num in range(3, n+1, 2):
        is_prime = True
        for i in range(3, int(num**0.5)+1, 2):
            if num % i == 0:
                is_prime = False
                break
        if is_prime:
            result.append(num)
    return result

def squares(n):
    return [i*i for i in range(1, n+1)]

if hostname == "web1":
    numbers = fibonacci(20)
elif hostname == "web2":
    numbers = primes(100)
else:  # web3
    numbers = squares(20)

print(" ".join(str(x) for x in numbers))
