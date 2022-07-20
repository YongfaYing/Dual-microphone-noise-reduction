clc
clear 
close all

%加载一段声音（matlab自带敲锣声）
%load gong;   %产生一个y和Fs
path='E:\datasets\空调噪声0.02秒.wav';
[music_src,Fs]=audioread(path);
%采样频率
%Fs = 8192;  
%采样周期
dt=1/Fs;
%music_src为声源
%music_src=y;       

%设置两个麦克风坐标
mic_d=1;
mic_x=[-mic_d mic_d];
mic_y=[0 0];
%plot(mic_x,mic_y,'x');
%axis([-5 5 -5 5])   %坐标轴的范围
%hold on;  %绘制多条曲线
%quiver(-5,0,10,0,1,'color','black');  %带箭头的直线，quiver(x,y,u,v,scale) 其中，x,y表示起点坐标，u表示水平延伸范围，v表示垂直延伸范围
%quiver(0,-5,0,10,1,'color','black');  %其实是画了x轴y轴
s_x_all=[];
s_y_all=[];
angel_all=[];
delay_all=[];
tic
time=20;
for t=0.02:0.02:time   %包含首尾
    disp(t);
    t1=clock;
    %声源位置
    s_x=unifrnd(-20,20);
    s_y=unifrnd(-20,20);
    s_x_all(end+1)=s_x;
    s_y_all(end+1)=s_y;
    %plot(s_x,s_y,'o');
    %quiver(s_x,s_y,-s_x-mic_d,-s_y,1);
    %quiver(s_x,s_y,-s_x+mic_d,-s_y,1);

    %求出距离
    dis_s1=sqrt((mic_x(1)-s_x).^2+(mic_y(1)-s_y).^2);
    dis_s2=sqrt((mic_x(2)-s_x).^2+(mic_y(2)-s_y).^2);
    c=340;  %速度
    delay=abs((dis_s1-dis_s2)./340);  %实际延时
    delay_all(end+1)=delay;

    %设置延时   以下为模拟，以上为模拟用的数据
    music_delay = delayseq(music_src,delay,Fs);  %模拟时延，参数为(数据，延时时间，采样率)
    %figure(2);   %建立第二幅图
    %subplot(211);  %subplots是设置子图的，211是指在本区域里显示2行1列个图像，最后的1表示本图像显示在第一个位置。
    %plot(music_src);   %原始声音的波形
    %axis([0 length(music_src) -2 2]);
    %subplot(212);
    %plot(music_delay);  %模拟的延时声音的波形
    %axis([0 length(music_delay) -2 2]);

    %gccphat算法,matlab自带
    %[tau,R,lag] = gccphat(music_delay,music_src,Fs);
    %disp(tau);   %相当于print
    %figure(3);
    %t=1:length(tau);
    %plot(lag,real(R(:,1)));

    %cc算法
    [rcc,lag]=xcorr(music_delay,music_src);
    %figure(4);
    %plot(lag/Fs,rcc);
    %[M,I] = max(abs(rcc));
    %lagDiff = lag(I);
    %timeDiff = lagDiff/Fs;
    %disp(timeDiff);

    %gcc+phat算法，根据公式写
    RGCC=fft(rcc);
    rgcc=ifft(RGCC*1./abs(RGCC));
    %figure(5);
    %plot(lag/Fs,rgcc);
    [M,I] = max(abs(rgcc));
    lagDiff = lag(I);
    timeDiff = lagDiff/Fs;
    disp(timeDiff);


    %计算角度,这里假设为平面波
    %dis_r=tau*c;
    %angel=acos(tau*c./(mic_d*2))*180/pi;
    angel=acos(timeDiff*c./(mic_d*2))*180/pi;
    if dis_s1<dis_s2
        angel=180-angel;
    end
    disp(angel);
    angel_all(end+1)=angel;
    t2=clock;
    %etime(t2,t1)
    while toc<t   %利用tic,toc实现精准延时
    end
end
toc
outpath='D:\matlab code\gcc_output\20ms\angel.csv';
delaypath='D:\matlab code\gcc_output\20ms\delay.csv';
csvwrite(outpath,angel_all')
csvwrite(delaypath,delay_all')
