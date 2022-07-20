clc
clear 
close all

path='E:\datasets\L-R.wav'; %双声道音频
[music_src,Fs]=audioread(path);

corr_timediff=[];
gcc_timediff=[];
angel_all=[];
B_all=[];
out_sig=[];
t1=clock;
f=0;
for i=1:320:length(music_src(:,1))-mod(length(music_src(:,1)),320)   %每20ms检测一次
    f=f+1;
    disp(f);
    %waveform=figure(f*3-2);
    %subplot(211);  %subplots是设置子图的，211是指在本区域里显示2行1列个图像，最后的1表示本图像显示在第一个位置。
    %plot(music_src(i:i+320,1));   
    %axis([0 length(music_src) -2 2]);
    %subplot(212);
    %plot(music_src(i:i+320,2));  
    %axis([0 length(music_delay) -2 2]);
    %waneform_path=['D:\matlab code\gcc_output\dual_track\',num2str(f),'_waveform.jpg'];
    %print(waveform,'-djpeg',waneform_path)

    %cc算法
    [rcc,lag]=xcorr(music_src(i:i+320,1),music_src(i:i+320,2));
    %corr=figure(f*3-1);
    %plot(lag/Fs,rcc);
%     corr_path=['D:\matlab code\gcc_output\dual_track\',num2str(f),'_corr.jpg'];
%     print(corr,'-djpeg',corr_path)
    [M,I] = max(abs(rcc));
    lagDiff = lag(I);
    corr_timeDiff = lagDiff/Fs;
    corr_timediff(end+1)=corr_timeDiff;

    %gcc+phat算法，根据公式写
    RGCC=fft(rcc);
    rgcc=ifft(RGCC*1./abs(RGCC));
%     gcc=figure(f*3);
%     plot(lag/Fs,rgcc);
%     gcc_path=['D:\matlab code\gcc_output\dual_track\',num2str(f),'_gcc.jpg'];
%     print(gcc,'-djpeg',gcc_path)
    [M,I] = max(abs(rgcc));
    lagDiff = lag(I);
    gcc_timeDiff = lagDiff/Fs;
    gcc_timediff(end+1)=gcc_timeDiff;
    
    mic_d=0.06;   %两个麦克风之间的距离
    c=340;
    angel=acos(gcc_timeDiff*c./(mic_d*2))*180/pi-90;
    disp(angel);
    angel_all(end+1)=angel;
    
    %%LCMV
    mic=2;                                     % 用于接收的麦克风的数量
    L=320;                                    % 在计算中使用了多少个采样点，暂时定为500个 
    thetas=angel;                                % 信号入射角度 
    thetai=[-30 30];                          % 干扰入射角度 
    n=[0:mic-1]';                               % 构造一个一维列矩阵 

    vs=exp(-j*pi*n*sin(thetas/180*pi));       % 信号方向矢量 
    vi=exp(-j*pi*n*sin(thetai/180*pi));       % 干扰方向矢量 
    %关于 vs 和 vi 是怎么来的，将在下面介绍。

    fs=16000;                                  % 信号频率
    t=[0:1:L-1]/200;                          % 构造时间变量
    snr=10;                                   % 信噪比 
    inr=10;                                   % 干噪比

    %构造有用信号 
    %xs=sqrt(10^(snr/10))*vs*exp(j*2*pi*f*t);    %shape=(2,320)
    path='E:\datasets\L-R.wav';
    [tar_sig,Fs]=audioread(path);
    xs=tar_sig(i:i+L-1,:)';
    %构造干扰信号
    xi=sqrt(10^(inr/10)/2)*vi*[randn(length(thetai),L)+j*randn(length(thetai),L)];
    %产生随机噪声
    noise=[randn(mic,L)+j*randn(mic,L)]/sqrt(2); 

    X=xs+noise;                              % 构造出来的含噪声的接收到的信号
    R=X*X'/L;                                % LCMV 方法中的 R 矩阵
    wop1=inv(R)*vs/(vs'*inv(R)*vs);          % 这里直接套用 LCMV 计算公式
    sita=90*[-1:0.001:1];                    % 扫描方向范围，共2001个
    v=exp(-j*pi*n*sin(sita/180*pi));         % 扫描方向矢量 
    B=abs(wop1'*v);                          % 求不同角度的增益
    B_all=[B_all,B'];
    %out_signal=real(wop1'*xs);   %只取实部
    out_signal=wop1'*xs;      %取复数
    out_sig=[out_sig out_signal];
    %lcmv_figure=figure(f);
    %plot(sita,20*log10(B/max(B)),'k'); 
    %title('波束图');xlabel('角度/degree');ylabel('波束图/dB'); 
    %grid on   %显示轴网格线
    %axis([-90 90 -50 0]); 
    %lcmv_path=['D:\matlab code\gcc_output\lcmv\',num2str(f),'_corr.jpg'];
    %print(lcmv_figure,'-djpeg',lcmv_path)
    %hold off   %再画另一幅图时，原来的图就看不到了，在轴上绘制的是新图，原图被替换了
    %hold on
end
angel_path='D:\matlab code\gcc_output\lcmv\angel.csv';
csvwrite(angel_path,angel_all')    %保存声源角度
B_path='D:\matlab code\gcc_output\lcmv\B.csv';
csvwrite(B_path,B_all')            %保存的不同角度的增益值
src_path='D:\matlab code\gcc_output\lcmv\src_sig.csv';
csvwrite(src_path,music_src)       %原双声道数据
out_path='D:\matlab code\gcc_output\lcmv\out_sig.csv';
csvwrite(out_path,out_sig')        %生成的输出信号数据
out_sig_path='D:\matlab code\gcc_output\lcmv\output.wav';
audiowrite(out_sig_path,out_sig',fs);    %保存生成的输出增益信号