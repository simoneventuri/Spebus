import matplotlib.pyplot as plt
import pymc3 as pm
import theano
import numpy as np
np.random.seed(42)
pm.set_tt_rng(42)

TPoints = np.array([6000.0, 8000.0, 10000.0, 12000.0, 14000.0])
KPoints = np.log(np.array([0.1363251472e-12, 0.3358452670e-10, 0.3703777980e-10, 0.3789961214e-10, 0.3849622717e-10]))

with pm.Model() as mdl_fish:
    A  = pm.Normal('A',  mu=0.0, sd=0.01,   testval=0.0)
    n  = pm.Normal('n',  mu=0.0, sd=1.0,    testval=0.0)
    Td = pm.Normal('Td', mu=0.0, sd=1.e5,   testval=0.0)
    K  = A * TPoints**n * theano.tensor.exp(- Td/TPoints)
    Sigma = pm.Lognormal('Sigma', mu=0.01,  sd=2.0,   testval=20.0)
    y     = pm.Normal('y', mu=K, observed=KPoints)
    hmc_trace = pm.sample(draws=5000, tune=1000, cores=2)
    pm.traceplot(hmc_trace)
    pm.summary(hmc_trace)
