from joblib import Memory
mem = Memory('.')

from scipy.integrate import solve_ivp
import nava

@mem.cache
def solution(k):
    nu = 1
    Vspan = (0, 2)
    Fa0 = 1

    def ode(V, Fa, k):
        return -k * Fa / nu

    sol = solve_ivp(ode, Vspan, (Fa0,), args=(k,))
    nava.play('../../../../cash-register-fake-88639.mp3')
    return sol

print(solution(0.1))
