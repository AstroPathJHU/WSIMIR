function [ab,cd,e,f] = newtform(reg,ref)

Vx = [cov(ref(:,1),reg(:,1));cov(reg(:,1),ref(:,2))];
vx = Vx([5;7]);
Vy = [cov(ref(:,1),reg(:,2));cov(reg(:,2),ref(:,2))];
vy = Vy([5;7]);
M = [[cov(ref(:,1),ref(:,1));cov(ref(:,1),ref(:,2))] [cov(ref(:,1),ref(:,2));cov(ref(:,2),ref(:,2))]];
m = reshape(M([5;7;13;15]),2,2);

% ab = inv(m)*vx;
ab = m\vx;
% cd = inv(m)*vy;
cd = m\vy;


e = mean(reg(:,1)) - ab(1)*mean(ref(:,1)) - ab(2)*mean(ref(:,2));
f = mean(reg(:,2)) - cd(1)*mean(ref(:,1)) - cd(2)*mean(ref(:,2));


