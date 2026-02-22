function [LL]=LLVAR(theta,Y,Z,n,p)
T=length(Z);
C=reshape(theta(1:n^2),n,n);

A=reshape(theta(n^2+1:end),n,n*p);
Omega=C*C';
Omegainv=eye(n)/Omega;
res= Y-A*Z;
LL=0;
ldO = log(det(Omega));
for t=1:T-1
LL=LL-0.5*(ldO + res(:,t)'*Omegainv*res(:,t));
end
