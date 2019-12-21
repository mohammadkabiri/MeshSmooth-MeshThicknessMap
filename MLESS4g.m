function [data] = MLESS4g()
%%%  Markerless Object Tracking
%%%  Mohammad Mahdi Kabiri [ mcivilkabiri@yahoo.com ], 2014 ©
fprintf('Mohammad Mahdi Kabiri [ mcivilkabiri@yahoo.com ], 2014 ©\n\n');
 try
%% RUN SETTING - inputs
CCth=0.0;

ROI_H=5; % Region of interest, half of height
ROI_w=5 ; % Region of interest, half of width
ROS_H=20 ;% Region of search , height
ROS_w=60 ;% Region of search , width
move_ROS=0;  % Region of search follows the tracker 1:on 0:off ... in progress 
method=1   ;   % 1:CC_m_fast  ...? ... in progress --> 
subpixel=1 ;% Using Subpixel Method
powimg=0; % increase contrast>1 , decrease contrast<1
scale=0 ;% pixel * Scale = Real Size --> perspective !!!!
ROI_rectdraw=0; % Optional, ... in progress
ROS_rectdraw=0 ;% Optional, ... in progress
answer=inputdlg({'image files:','image type:',},'img or vid?',1,{'0','jpg'});
         ImgDir=str2num(answer{1}); % 
         ImgType=['*.',answer{2}];
fpsc=30;
freqa=100;
nameOfexternalfile='pos1'; % String specifying the name of output file

%% FILE
% input:
% 1- movie or video file
% 2- group of images

if ImgDir==0
 [fi,di]=uigetfile({'*.*'},'open video file:');
  mov = VideoReader([di,fi]);
else
   di=uigetdir(cd); 
   images=dir([di,'\',ImgType]);
end

  %% SET ON FILE
  
  if ImgDir==0 % Movie
        nof = mov.NumberOfFrames %Number of frames
        dv=mov.Duration %Duration
        fps=mov.FrameRate % the frame rate of the movie [1/s]
        vh = mov.Height % the height of the movie 
        vw = mov.Width % the width of the movie
        fi % String specifying the name of the file
  else % Images
      img=imread([di,'\',images(1).name]);
      nof = numel(images)
      dv=  nof/fpsc
      fps=fpsc
      vh = size(img,1)
      vw = size(img,2)
      fi=images(1).name;
      fi
  end
        answer=inputdlg({'input center frame:','input start frame:',...
            'input end frame:','input fps:','input step:','name:','minimum Score%:'},...
            ['enter DATA_',fi,':'],1,...
            {'1','1',num2str(nof),num2str(fps),'1','_dat0','80'});
        cframe=str2num(answer{1}) % 
        stf=str2num(answer{2}); % start frame >= 1
        enf=str2num(answer{3}); % end frame <= nof
        fps=str2num(answer{4}); % FPS  --> dt=1/fps [s] Default:the fps of the movie
        stp=str2num(answer{5}); % step of reading for( int i = stf; i < enf; i+ = stp )
        nameOfexternalfile=answer{6};
        CCth=str2num(answer{7})/100;
        
       if ImgDir==0  % reading the first image  
        img=read(mov,stf);
       else
        img=imread([di,'\',images(stf).name]);
       end

        figure();
        imshow(img);
        hold on;
        axis([0.0 vw+1 0.0 vh+1]);

        
        set(gcf,'name','set brightness and contrast');
         cont=1;
         brit=0;
         but=0;
        while but~=1 % % apply: Press left mouse button to apply 
        [~,~,but]=ginput(1); % keyboard press callback @ me
        switch but
            case 28  % press left key to decrease contrast
             cont=cont-0.2; % con_incr=0.2
            case 29  % press right key to increase contrast
             cont=cont+0.2;
            case 30  % press up key to increase brightness
             brit=brit+10; % bri_incr=10
            case 31  % press down key to increase brightness
             brit=brit-10;
            case 8 % backspace to  main
                brit=0;
                cont=1; 
        end
%               J = mat2gray(imadjust(g,stretchlim(g),[c d])); --> optional
%               its beter than cont*img+brit
%               in progress ...
               J=cont*img+brit; % ... brightness and contrast  ...
               
%                cont=0.25
%                bl=mean(mean(img));
%                brit=mean(0.2*bl)
%                J=cont*img+brit;
               
               
               if powimg>0
                    J=im2uint8((im2double(J)).^powimg);  % power !!! -> @ me :O !!!
               end
                
               % flip
%                  J=(fliplr(J)+J)*0.5;
               % flip
               
              clf(gcf);
              imshow(J); % show ---> slow !!!
              hold on;
         end
                set(gcf,'name','set point');

        but=0;
        vww=vw;vhh=vh;
        while but~=1 % apply: Press left mouse button to apply 
        [xx,yy,but]=ginput(1); % keyboard press callback @ me
        if but==3 % zoom in: Press right mouse button to zoom in 
           zoom(2);
           vww=vww/2;vhh=vhh/2;
           axis([xx-vww/2,xx+vww/2,yy-vhh/2,yy+vhh/2]);
        elseif but==2  % zoom out: Press middle mouse button to zoom out 
           zoom(0.5);
           vww=min(vww*2,vw);vhh=min(vhh*2,vh);
           axis([xx-vww/2,xx+vww/2,yy-vhh/2,yy+vhh/2]);
        end
        end
        Xc=xx
        Yc=yy
        
        %
%          Xc=200,Yc=200;
        %
        
        plot(Xc,Yc,'+k');
        
        
      set(gcf,'name','draw template region');

        
         %--> in progress ... @ me 
         if ROI_rectdraw==1
            hr=imrect(gca)%,'position',[max(yc-ROI_w,0),max(xc-ROI_H,0),min(2*ROI_w,vw-1),min(2*ROI_H,vh-1)]);
            rect=round(wait(hr));
             rect([1,2])=([max(rect(1),1),max(rect(2),1)]);
             rect([3,4])=([min(rect(3),vw-rect(1)),min(rect(4),vh-rect(2))]);
         else
        rect([1,2])=([max(Xc-ROI_w,1),max(Yc-ROI_H,1)]);
        rect([3,4])=([min(2*ROI_w,vw-rect(1)),min(2*ROI_H,vh-rect(2))]); %--> convert to integer
        rect=round(rect);
         hr=imrect(gca);
         rect=wait(hr)
         end
        rect=round(rect)
        rectangle('position',rect,'edgecolor','r'); %% show ---> slow !!!
        temp=imcrop(J,rect);
        
         offset=[Xc,Yc]-(rect([1,2])+rect([3,4]));
        
        I_tempssd=im2double(rgb2gray(temp));
         pause(1.05); % Wait until you see the result
        
               set(gcf,'name','draw search region');

           if ROS_rectdraw==1
            hr2=imrect(gca)%,'position',[max(yc-ROI_w,0),max(xc-ROI_H,0),min(2*ROI_w,vw-1),min(2*ROI_H,vh-1)]);
            rectF=round(wait(hr2));
             rectF([1,2])=([max(rectF(1),1),max(rectF(2),1)]);
             rectF([3,4])=([min(rectF(3),vw-rectF(1)),min(rectF(4),vh-rectF(2))]);
           else
               
            rectF([1,2])=([max(Xc-0.5*ROS_w,1),max(Yc-0.5*ROS_H,1)]);
            rectF([3,4])=([min(ROS_w,vw-rectF(1)),min(ROS_H,vh-rectF(2))]); % select and update the search region
            rectF=round(rectF);
            rectangle('position',rectF,'edgecolor','y'); % draw the results in figure
            hr=imrect(gca);
            rectF=wait(hr)
            
           end
           rectF=round(rectF)

                     rectangle('position',rectF,'edgecolor','y'); % draw the results in figure
                     pause(1.05);

         
         sc=1.0;
        if scale==1 % scale of image: RealWorldSize/NumOfPixels
        figure(36542);
        imshow(J);
        h = imline;
        ph = wait(h);
        L=inputdlg('Enter Length:','Scaling Photo:',1,{'40.0'});
        L= str2double(L{1});
        sc=L/rssq(ph(2,:)-ph(1,:));
        end
        pause(1.05); % Wait until you see the result
        close all; % Refresh all the Figs


%%    StartPos=Pivot point 
if cframe~=stf   % pivot point frame ~= start frame  (cframe~=stf)              %             CC=CC_m_fast(J,I_tempssd);
       if ImgDir==0
        img=read(mov,cframe);
       else
        img=imread([di,'\',images(cframe).name]);
       end
            img=cont*img+brit;
            figure();
        imshow(img);
        hold on;
        axis([0.0 vw+1 0.0 vh+1]);
      
            but=0;
            vww=vw;vhh=vh;
        while but~=1
        [xx,yy,but]=ginput(1); % key press callback @ me
        if but==3
           zoom(2);
           vww=vww/2;vhh=vhh/2;
           axis([xx-vww/2,xx+vww/2,yy-vhh/2,yy+vhh/2]);
        elseif but==2
           zoom(0.5);
           vww=min(vww*2,vw);vhh=min(vhh*2,vh);
           axis([xx-vww/2,xx+vww/2,yy-vhh/2,yy+vhh/2]);
        end
        end
         x0=xx,y0=yy;   
            
else        

            x0=Xc;
            y0=Yc;
end
close all;  % [x0,y0] --> pivot point coordinate in pixel => (0,0)

save([di,fi(1:end-4),nameOfexternalfile,'_datset.mat']);

%%
% parallel ...> in progress
%%    RUN 
clearvars -except di fi nameOfexternalfile;
close all;
load([di,fi(1:end-4),nameOfexternalfile,'_datset.mat']);

CCth=0.0
Cthresh=0.0
tp='pause(0.00001); '

ALLDAT={};

xcenter=zeros(ceil((enf-stf)/stp),1);  % initial values =0
ycenter=xcenter;
xpa=xcenter;
ypa=xcenter;
CCmax=xcenter;
 STEP=0;
 STEPp=0;
   stfp=stf;
     frame=stf;

         fg=figure('name',fi);
         % set(fg,'CloseRequestFcn',@my_closereq); --> ... in progress @me
      xcp=Xc;ycp=Yc; % initial values
      
        for frame=stf:stp:enf  % The main LOOP 

            %clc; %  clear the command window
            gcf();
       if ImgDir==0
        img=read(mov,frame);
       else
        img=imread([di,'\',images(frame).name]);
       end

            img=cont*img+brit; % setting the contrast and the brightness
            if powimg>0
            img=im2uint8((im2double(img)).^powimg); 
            end
             subplot(2,6,[1:3,7:9])
            cla(gca); 
            imshow(img);
            hold on;
            axis on;
            axis([0.0 vw+1 0.0 vh+1]);
            plot(x0,y0,'+c','markersize',10);
            text(0,20,sprintf('frame:%d/%d          %.2f %%',frame,enf,((frame-stfp)/(enf-stfp))*100),'BackgroundColor',[.7 .5 .6]); %printing
             
            
            if frame>stf 
                xcp=x_subpixel;
                ycp=y_subpixel;
            end

            rectF([1,2])=round([max(xcp-0.5*rectF(3),1),max(ycp-0.5*rectF(4),1)]);
            rectF([3,4])=round([min(rectF(3),vw-rectF(1)),min(rectF(4),vh-rectF(2))]); % select and update the search region
              
%             rectangle('position',rectF,'edgecolor','y'); % draw the results in figure
            J=imcrop(img,rectF); % crop the selected region to analyze
% try
          
            switch method
                case 1  %--> CC method 
            J=im2double(rgb2gray(J));
            end

if max(J(:))<Cthresh
    errrcall(); 
end
CC=normxcorr2(I_tempssd,J);
cmax=max(max(CC));
% CCth=0.95;
if cmax>CCth
[yp,xp]=find(CC==cmax);
            N=1;
            fx = fit([xp-N:xp+N]',CC(yp,xp-N:xp+N)','gauss1'); 
            fy = fit([yp-N:yp+N]',CC(yp-N:yp+N,xp),'gauss1');
                 xpsp=fx.b1;
                 ypsp=fy.b1;
                 
                 if abs(xpsp-xp)>1.2
                     xpsp=xp;
                 end
                 if abs(ypsp-yp)>1.2
                     ypsp=yp;
                 end


  % correction of 1 px
        cp=1;
           xp=xp+rectF(1)+offset(1)-cp;
           yp=yp+rectF(2)+offset(2)-cp;
           x_subpixel=xpsp+rectF(1)+offset(1)-cp;
           y_subpixel=ypsp+rectF(2)+offset(2)-cp;
           
 % correction of 1 px

           plot(x_subpixel,y_subpixel,'oy'); %print
           plot(x_subpixel,y_subpixel,'+k'); %print
           eval(tp);
           else
              errrcall(); 
           end
% catch
%     text(0,30,'error...','color','r');
%     xp=NaN;
%     yp=NaN;
%     x_subpixel=NaN;
%     y_subpixel=NaN;
%     CC=0.0;
%  end
%            
                       STEP=STEP+1;
           xpa(STEP)=xp;
           ypa(STEP)=yp;
           xcenter(STEP)=x_subpixel;  % append to xcenter array
           ycenter(STEP)=y_subpixel;  % append to ycenter array
           CCmax(STEP)=max(CC(:));
           
           if STEP>1
            subplot(2,6,5:6)
            cla(gca)
% hold on
            plot(xcenter(1:STEP))
            ylabel('X[pix]');
            xlabel('Frame');
            subplot(2,6,11:12)
             cla(gca)
% hold on
            plot(ycenter(1:STEP))
            ylabel('Y[pix]');
            xlabel('Frame');
           end
%            pause()
        end  
      stf=stfp; 
      enf=frame;
      
%%    Results

frameall=(stfp:stp:enf);
           
            idnan=isnan(xcenter);
            idc=1:length(xcenter);
          
%        xcenter=interp1(idc(idnan),xcenter(idnan),idc,'spline');
%        ycenter=interp1(idc(idnan),ycenter(idnan),idc,'spline');
%        xpa=interp1(idc(idnan),xpa(idnan),idc,'spline');
%        ypa=interp1(idc(idnan),ypa(idnan),idc,'spline');

   xcenter(idnan)=[];
   ycenter(idnan)=[];
   xpa(idnan)=[];
   ypa(idnan)=[];
   CCmax(idnan)=[];
   frameall(idnan)=[];
   
        dt=1.0*stp/fps; %--> time_step
        t=frameall*dt; % --> time array
        x2=(xcenter).*sc; %--> Scale to real sizes
        y2=(ycenter).*sc; %--> Scale to real sizes
       
        save([di,fi(1:end-4),nameOfexternalfile,'_2.mat']);

        
%%      print
        figure('name','xdir','numbertitle','off');
        plot(t,x2);
        title('dis');
        xlabel('t[s]');
        ylabel('x[u]');
            saveas(gcf,[[di,fi,'_Xdisp',nameOfexternalfile],'.png']);
            saveas(gcf,[[di,fi,'_Xdisp',nameOfexternalfile],'.fig']);

        figure('name','ydir','numbertitle','off');
        plot(t,y2);
        title('dis');
        xlabel('t[s]');
        ylabel('y[u]');
            saveas(gcf,[[di,fi,'_Ydisp',nameOfexternalfile],'.png']);
            saveas(gcf,[[di,fi,'_Ydisp',nameOfexternalfile],'.fig']);

 
 %%  EXPORT DATA  @... IN PROGRESS ~less size, more spead 
 
 
data=[frameall(:),t(:),xcenter(:),ycenter(:),CCmax(:)]; 
 
 
        fid=fopen([di,'\',fi(1:end-4),'_',nameOfexternalfile,'.txt'],'w'); % Open or create new file for writing. Discard existing contents, if any.
 
        fprintf(fid,'MMK MARKERLESS OUT of %s\n',fi)                                    % header line of file 0
        fprintf(fid,'mmahdikabiri@gmail.com\n'); 
         fprintf(fid,['\n pixel 2 unit scale=%.4f \n'],sc);    
        % header line of file 0
        fprintf(fid,'center frame=%d \t start frame=%d \t end frame=%d \t step=%d \t fpsc:%.4f \n',cframe,stf,enf,stp,fps);    % header line of file 1
        if scale==1
        fprintf(fid,'scale stick=[%.4f,%.4f,%.4f,%.4f] \t inputL=%.4f \t scale=%.4f \n',ph(1,1),ph(1,2),ph(2,1),ph(2,2),L,sc); % header line of file 3
        end
        fprintf(fid,'\n');                                                                                                     % header line of file 5
        fprintf(fid,'\n%s\t%s\t%s\t%s\t%s\n','frame','time[s]','xp','yp','quality');                                         % table columns title 6
        for i=1:size(data,1)
            fprintf(fid,'%.5f\t%.5f\t%.5f\t%.5f\t%.5f\n',data(i,:));  % writing data to output line 7:end
        end
        fclose('all');
%         dlmwrite([di,fi(1:end-4),'_',name,'.txt'],data,'-append','roffset',0,'precision', '%.3f','delimiter','\t','newline','pc');
%         dlmwrite([di,fi(1:end-4),'_',name,'_pixval.txt'],data.*1/sc,'delimiter','\t','newline','pc');
      save([di,fi(1:end-4),nameOfexternalfile,'_final.mat']);                  
      dlmwrite([di,fi(1:end-4),'_',nameOfexternalfile,'_pixval.txt'],data,'delimiter','\t','newline','pc');
disp('finished successfully...');
catch
   data=nan;
   return
end


