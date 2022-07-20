clc
clear 
close all

path='E:\datasets\L-R.wav';
[music_src,Fs]=audioread(path);

corr_timediff=[];
gcc_timediff=[];
angel_all=[];
t1=clock;
f=0;
for i=1:320:length(music_src(:,1))-mod(length(music_src(:,1)),320)   %ÿ20ms���һ��
    f=f+1;
    disp(f);
    %waveform=figure(f*3-2);
    %subplot(211);  %subplots��������ͼ�ģ�211��ָ�ڱ���������ʾ2��1�и�ͼ������1��ʾ��ͼ����ʾ�ڵ�һ��λ�á�
    %plot(music_src(i:i+320,1));   
    %axis([0 length(music_src) -2 2]);
    %subplot(212);
    %plot(music_src(i:i+320,2));  
    %axis([0 length(music_delay) -2 2]);
    %waneform_path=['D:\matlab code\gcc_output\dual_track\',num2str(f),'_waveform.jpg'];
    %print(waveform,'-djpeg',waneform_path)

    %cc�㷨
    [rcc,lag]=xcorr(music_src(i:i+320,1),music_src(i:i+320,2));
    %corr=figure(f*3-1);
    %plot(lag/Fs,rcc);
%     corr_path=['D:\matlab code\gcc_output\dual_track\',num2str(f),'_corr.jpg'];
%     print(corr,'-djpeg',corr_path)
    [M,I] = max(abs(rcc));
    lagDiff = lag(I);
    corr_timeDiff = lagDiff/Fs;
    corr_timediff(end+1)=corr_timeDiff;

    %gcc+phat�㷨�����ݹ�ʽд
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
    
    mic_d=0.06;
    c=340;
    angel=acos(gcc_timeDiff*c./(mic_d*2))*180/pi;
    disp(angel);
    angel_all(end+1)=angel;

end
timediff_path='D:\matlab code\gcc_output\dual_track\timediff.csv';
csvwrite(timediff_path,gcc_timediff')
angel_path='D:\matlab code\gcc_output\dual_track\angel.csv';
csvwrite(angel_path,angel_all')