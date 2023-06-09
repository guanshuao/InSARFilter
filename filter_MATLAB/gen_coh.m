function coh = gen_coh(cpx)
% ----------------------------------
% 计算干涉图的伪相干系数
% 输入：
% cpx           干涉图复数矩阵
% 输出：
% coh         整个干涉图的伪相干系数，介于01之间的常数
% ----------------------------------


% 创建cpx的副本
cpx_copy = cpx;

% 将NaN值替换为0
cpx_copy(isnan(cpx_copy)) = 0;


% 计算干涉图的相干系数
sum_cpx = abs(sum(cpx_copy(:)));  % 计算cpx中非NaN元素的和的绝对值

abs_cpx = abs(cpx_copy);          % 计算cpx中所有元素的绝对值
sum_abs_cpx = sum(abs_cpx(:));   % 计算cpx中非NaN元素的绝对值的和


coh = sum_cpx / sum_abs_cpx;   % 计算整个干涉图的相干系数

end
