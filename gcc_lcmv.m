clc
clear 
close all

path='E:\datasets\L-R.wav'; %˫������Ƶ
[music_src,Fs]=audioread(path);

corr_timediff=[];
gcc_timediff=[];
angel_all=[];
B_all=[];
out_sig=[];
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
    
    mic_d=0.06;   %������˷�֮��ľ���
    c=340;
    angel=acos(gcc_timeDiff*c./(mic_d*2))*180/pi-90;
    disp(angel);
    angel_all(end+1)=angel;
    
    %%LCMV
    mic=2;                                     % ���ڽ��յ���˷������
    L=320;                                    % �ڼ�����ʹ���˶��ٸ������㣬��ʱ��Ϊ500�� 
    thetas=angel;                                % �ź�����Ƕ� 
    thetai=[-30 30];                          % ��������Ƕ� 
    n=[0:mic-1]';                               % ����һ��һά�о��� 

    vs=exp(-j*pi*n*sin(thetas/180*pi));       % �źŷ���ʸ�� 
    vi=exp(-j*pi*n*sin(thetai/180*pi));       % ���ŷ���ʸ�� 
    %���� vs �� vi ����ô���ģ�����������ܡ�

    fs=16000;                                  % �ź�Ƶ��
    t=[0:1:L-1]/200;                          % ����ʱ�����
    snr=10;                                   % ����� 
    inr=10;                                   % �����

    %���������ź� 
    %xs=sqrt(10^(snr/10))*vs*exp(j*2*pi*f*t);    %shape=(2,320)
    path='E:\datasets\L-R.wav';
    [tar_sig,Fs]=audioread(path);
    xs=tar_sig(i:i+L-1,:)';
    %��������ź�
    xi=sqrt(10^(inr/10)/2)*vi*[randn(length(thetai),L)+j*randn(length(thetai),L)];
    %�����������
    noise=[randn(mic,L)+j*randn(mic,L)]/sqrt(2); 

    X=xs+noise;                              % ��������ĺ������Ľ��յ����ź�
    R=X*X'/L;                                % LCMV �����е� R ����
    wop1=inv(R)*vs/(vs'*inv(R)*vs);          % ����ֱ������ LCMV ���㹫ʽ
    sita=90*[-1:0.001:1];                    % ɨ�跽��Χ����2001��
    v=exp(-j*pi*n*sin(sita/180*pi));         % ɨ�跽��ʸ�� 
    B=abs(wop1'*v);                          % ��ͬ�Ƕȵ�����
    B_all=[B_all,B'];
    %out_signal=real(wop1'*xs);   %ֻȡʵ��
    out_signal=wop1'*xs;      %ȡ����
    out_sig=[out_sig out_signal];
    %lcmv_figure=figure(f);
    %plot(sita,20*log10(B/max(B)),'k'); 
    %title('����ͼ');xlabel('�Ƕ�/degree');ylabel('����ͼ/dB'); 
    %grid on   %��ʾ��������
    %axis([-90 90 -50 0]); 
    %lcmv_path=['D:\matlab code\gcc_output\lcmv\',num2str(f),'_corr.jpg'];
    %print(lcmv_figure,'-djpeg',lcmv_path)
    %hold off   %�ٻ���һ��ͼʱ��ԭ����ͼ�Ϳ������ˣ������ϻ��Ƶ�����ͼ��ԭͼ���滻��
    %hold on
end
angel_path='D:\matlab code\gcc_output\lcmv\angel.csv';
csvwrite(angel_path,angel_all')    %������Դ�Ƕ�
B_path='D:\matlab code\gcc_output\lcmv\B.csv';
csvwrite(B_path,B_all')            %����Ĳ�ͬ�Ƕȵ�����ֵ
src_path='D:\matlab code\gcc_output\lcmv\src_sig.csv';
csvwrite(src_path,music_src)       %ԭ˫��������
out_path='D:\matlab code\gcc_output\lcmv\out_sig.csv';
csvwrite(out_path,out_sig')        %���ɵ�����ź�����
out_sig_path='D:\matlab code\gcc_output\lcmv\output.wav';
audiowrite(out_sig_path,out_sig',fs);    %�������ɵ���������ź�