# Optimize a gaussianprocess

using GaP

#Training data

x=[-4.0,-3.0,-1.0,0.0,2.0];
y=[-2.0,0.0,1.0,2.0,-1.0];


#Specify mean and covariance function, not that default hyperparameters are l=1 and sigma²=1

mZero = mZERO()
se = SE()
gp = GP(x,y,mZero,se)
optimize!(gp, method=:l_bfgs, show_trace=true)
