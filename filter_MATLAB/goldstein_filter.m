function out_cpx=goldstein_filter(cpx, alpha, window_size, step_size)
% --------------------------------------------
% Goldstein滤波
% 输入参数：
%   cpx             需要滤波的干涉图复数矩阵
%   alpha           滤波参数alpha
%   window_size     滑动窗口大小
%   step_size       滑动窗口步长
%
% 输出：
%   out_cpx         滤波后的干涉图复数矩阵
% --------------------------------------------

% 构造均值卷积核
K = ones(3, 3);
K = K/sum(K(:));
K = fftshift(fft2(K));

% 构造权阵
if mod(window_size,2)~=0
    window_size=window_size-1;
end
x=[1:window_size/2];
[X,Y]=meshgrid(x,x);
X=X+Y;
weight=[X,fliplr(X)];
weight=[weight;flipud(weight)];

[rows,cols]=size(cpx);
out_cpx=zeros(rows,cols);

for ii=1:step_size:rows
    for jj=1:step_size:cols
        mm=ii+window_size-1;
        if mm>rows
            mm=rows;
        end
        nn=jj+window_size-1;
        if nn>cols
            nn=cols;
        end
        window=cpx(ii:mm,jj:nn);
        ww=weight(1:(mm-ii+1),1:(nn-jj+1));
        H=fft2(window);
        H=fftshift(H);
        % 使用均值卷积核平滑
        S = conv2(abs(H),K,'same');
        % 归一化 S
        S = S./max(S(:));
        S = S .^ alpha;
        H = H .* S;
        H=ifftshift(H);
        window=ifft2(H);
        out_cpx(ii:mm,jj:nn)=out_cpx(ii:mm,jj:nn)+window.*ww;
    end
end
% 掩膜原来是空值的像元
idx=angle(cpx)==0;
out_cpx(idx)=0;
idx=isnan(angle(cpx));
out_cpx(idx)=nan;