from pycse.hashcache import hashcache
import nava

@hashcache(verbose=True)
def f(a, b=1):
    nava.play('../../../../cash-register-fake-88639.mp3')
    return (a, b)

print(f(1))
