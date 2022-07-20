clc
clear 
close all

%����һ��������matlab�Դ���������
%load gong;   %����һ��y��Fs
path='E:\datasets\�յ�����0.02��.wav';
[music_src,Fs]=audioread(path);
%����Ƶ��
%Fs = 8192;  
%��������
dt=1/Fs;
%music_srcΪ��Դ
%music_src=y;       

%����������˷�����
mic_d=1;
mic_x=[-mic_d mic_d];
mic_y=[0 0];
%plot(mic_x,mic_y,'x');
%axis([-5 5 -5 5])   %������ķ�Χ
%hold on;  %���ƶ�������
%quiver(-5,0,10,0,1,'color','black');  %����ͷ��ֱ�ߣ�quiver(x,y,u,v,scale) ���У�x,y��ʾ������꣬u��ʾˮƽ���췶Χ��v��ʾ��ֱ���췶Χ
%quiver(0,-5,0,10,1,'color','black');  %��ʵ�ǻ���x��y��
s_x_all=[];
s_y_all=[];
angel_all=[];
delay_all=[];
tic
time=20;
for t=0.02:0.02:time   %������β
    disp(t);
    t1=clock;
    %��Դλ��
    s_x=unifrnd(-20,20);
    s_y=unifrnd(-20,20);
    s_x_all(end+1)=s_x;
    s_y_all(end+1)=s_y;
    %plot(s_x,s_y,'o');
    %quiver(s_x,s_y,-s_x-mic_d,-s_y,1);
    %quiver(s_x,s_y,-s_x+mic_d,-s_y,1);

    %�������
    dis_s1=sqrt((mic_x(1)-s_x).^2+(mic_y(1)-s_y).^2);
    dis_s2=sqrt((mic_x(2)-s_x).^2+(mic_y(2)-s_y).^2);
    c=340;  %�ٶ�
    delay=abs((dis_s1-dis_s2)./340);  %ʵ����ʱ
    delay_all(end+1)=delay;

    %������ʱ   ����Ϊģ�⣬����Ϊģ���õ�����
    music_delay = delayseq(music_src,delay,Fs);  %ģ��ʱ�ӣ�����Ϊ(���ݣ���ʱʱ�䣬������)
    %figure(2);   %�����ڶ���ͼ
    %subplot(211);  %subplots��������ͼ�ģ�211��ָ�ڱ���������ʾ2��1�и�ͼ������1��ʾ��ͼ����ʾ�ڵ�һ��λ�á�
    %plot(music_src);   %ԭʼ�����Ĳ���
    %axis([0 length(music_src) -2 2]);
    %subplot(212);
    %plot(music_delay);  %ģ�����ʱ�����Ĳ���
    %axis([0 length(music_delay) -2 2]);

    %gccphat�㷨,matlab�Դ�
    %[tau,R,lag] = gccphat(music_delay,music_src,Fs);
    %disp(tau);   %�൱��print
    %figure(3);
    %t=1:length(tau);
    %plot(lag,real(R(:,1)));

    %cc�㷨
    [rcc,lag]=xcorr(music_delay,music_src);
    %figure(4);
    %plot(lag/Fs,rcc);
    %[M,I] = max(abs(rcc));
    %lagDiff = lag(I);
    %timeDiff = lagDiff/Fs;
    %disp(timeDiff);

    %gcc+phat�㷨�����ݹ�ʽд
    RGCC=fft(rcc);
    rgcc=ifft(RGCC*1./abs(RGCC));
    %figure(5);
    %plot(lag/Fs,rgcc);
    [M,I] = max(abs(rgcc));
    lagDiff = lag(I);
    timeDiff = lagDiff/Fs;
    disp(timeDiff);


    %����Ƕ�,�������Ϊƽ�沨
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
    while toc<t   %����tic,tocʵ�־�׼��ʱ
    end
end
toc
outpath='D:\matlab code\gcc_output\20ms\angel.csv';
delaypath='D:\matlab code\gcc_output\20ms\delay.csv';
csvwrite(outpath,angel_all')
csvwrite(delaypath,delay_all')
