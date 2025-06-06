%% This code is modeling the individual farmer maximize the profit subject to the pollutant cumulation by
% choosing the mulch decay rate. Given the optimal disposal strategy is to not dispose any of the pre-tilled

 
function z0policy90P3
%% FORMULATION
demosetup(mfilename)
% Model parameters
a = [30360 1 0.1 0.005 5 0];
b = [0 0 1197.9 -0.5];
nu =[28785.02 10];
%ita 1 was 3.20, but we added 0.05 of residue which is A base level of residue from PE (or BDM for that matter) whether or not the mulch goes to a landfill

ita = [3.25 0.5 0.1 3.2 -0.5];
delta = 0.9;
w = 0.6;
p = 3;
z = 0;

                              	
    
% Model structure
model.func = @func;                             % model functions
model.params = {a,b,nu,ita,z,w,p};              % function parameters
model.discount = delta;                         % discount factor
model.ds = 1;                                   % dimension of continuous state
model.dx = 1;                                   % dimension of continuous action
model.ni = 0;                                   % number of discrete states
model.nj = 0;                                   % number of discrete actions

% Approximation structure
n    = 100;                                     	% number of collocation nodes
smin = 0;                                       	% minimum state
smax = 50;                                          % maximum state
basis = fundefn('spli',n,smin,smax);                % basis functions

%% SOLUTION
  
% Steady-state
qstar =((nu(2)+w*(-b(2)+b(4)*z)+a(2)*p)*(1-delta*ita(3))*(1-ita(3))+(a(6)...
    *(1-delta*ita(3))+delta*a(5)*(-ita(2)-ita(5)*z))*p*(ita(1)-ita(4)*z)+...
    a(3)*delta*(-ita(2)-ita(5)*z)*p*(1-ita(3)))/...
    ((-a(4)*(1-ita(3)*delta)+a(6)*delta*(ita(2)+ita(5)*z))*p*(1-ita(3))+(-a(6)*(1-delta*ita(3))...
    +(a(5)*delta*(ita(2)+ita(5)*z))*p*(-ita(2)-ita(5)*z))); 	% Choice variable
sstar = (ita(1)-ita(2)*qstar-ita(4)*z-ita(5)*z*qstar)/(1-ita(3));           % State Variable
lstar = p*(-a(3)-a(5)*sstar-a(6)*qstar)/(-delta*ita(3)+1);                            % Shadow price for pollutant
pistar = (p*(a(1)-a(2)*qstar-a(3)*sstar-0.5*a(4)*qstar.^2-0.5*a(5)*sstar.^2-a(6)*qstar.*sstar)...
        -nu(1)-nu(2)*qstar-w*(b(1)-b(2)*qstar+b(3)*z+b(4)*z*qstar))/(1-delta); % The present value of life time profit given the optimal choice

format long e
% check the condition that the optimal z=0. Check value <0
check = -w*(b(3)+b(4)*qstar)+delta*(-ita(4)-ita(5)*qstar)*lstar;
fprintf('check the condition that the optimal z=0. Check value <0 %5.2f\n' , check)
% Check the condition that the FOC=0
check1=-a(2)*p-a(4)*qstar*p-a(6)*sstar*p-nu(2)+w*b(2)-b(4)*z*w+delta*lstar*(-ita(2)-ita(5)*z);
fprintf('Check the condition that the FOC=0 %5.2f\n' , check1)
% Check model derivatives
dpcheck(model,sstar,qstar);
% Solve collocation equation
[c,s,v,q,resid] = dpsolve(model,basis);


max(v)



%% DPSOLVE FUNCTION FILE


function [out1,out2,out3] = func(flag,s,q,~,~,~,a,b,nu,ita,z,w,p)

switch flag
  case 'b'      % bounds
    out1 = ones(size(s))*0.9;
    out2 = ones(size(s));
    out3 = [];
  case 'f'      % Profit
    out1 = p*(a(1)-a(2)*q-a(3)*s-0.5*a(4)*q.^2-0.5*a(5)*s.^2-a(6)*q.*s)...
        -nu(1)-nu(2)*q-w*(b(1)-b(2)*q+b(3)*z+b(4)*z*q);
    out2 = -a(2)*p-a(4)*q*p-a(6)*s*p-nu(2)+w*b(2)-b(4)*z*w;
    out3 =  -a(4)*p*ones(size(s));
  case 'g'      % Motion of state variable
    out1 = ita(1)-ita(2)*q+ita(3)*s-ita(4)*z-ita(5)*q*z;
    out2 = (-ita(2)-ita(5)*z)*ones(size(s));
    out3 = zeros(size(s));
end