function [D,CUT]=balloonpop_trial(MOV,D,fig,varargin)
% [D,CUT] = balloonpop_trial(MOV,D,fig,varargin)
%
% extracts the statistics from the movement data
% for one trial.
%
% Does a nice display of each trial

% ------------------------------------------------
% Defaults
color={'r','b'};
colorp={'r.','b.'};
num={'0','1'};
side={'L','R'};
sample=5;
% ------------------------------------------------
% OPTIONS
vararginoptions(varargin,{'x'});


% ------------------------------------------------
% prepare Cutting
ms_pre=200;ms_post=600;
pre=ms_pre/sample;post=round(ms_post/sample);
CUT.t=[-ms_pre:sample:ms_post]';
CUT.PX=ones(length(CUT.t),1)*NaN;
CUT.PY=ones(length(CUT.t),1)*NaN;
CUT.VX=ones(length(CUT.t),1)*NaN;
CUT.VY=ones(length(CUT.t),1)*NaN;
CUT.v=ones(length(CUT.t),1)*NaN;
CUT.FX=ones(length(CUT.t),1)*NaN;
CUT.FY=ones(length(CUT.t),1)*NaN;

% ------------------------------------------------
% If we don't trip some bad trial warning, let's
% call this good
D.good = 1;

% ------------------------------------------------
% extract data
if (isempty(MOV))
    D.good = 0;
    return;
end;
if D.TN==41
  D.good = 0;
  return;
end

t=MOV(:,2);
sample=mean(diff(t)); %t(2)-t(1);
sampfreq=1000/sample;
state=MOV(:,1);
P=MOV(:,3:4);
C=MOV(:,5:6);
F=MOV(:,7:8);

% -------------------------------------------------
% Velocity, ForceMagnitude, and CursorDistance

[vh,Vh]=tangvelocity(P);
fmag(:,1)=sqrt(sum(F.^2,2));
cmag(:,1)=sqrt(sum(C.^2,2));

peakV = max(vh);

if peakV > 2.5 % must be a cursor jump
  D.good = 0;
  return;
end


at=findstart(vh>0.05*peakV,40);
D.velRT = round(t(at));
tmin = pre;
% -------------------------------------------------
% Cut trajectory

CUT.v(:,:,1)=cut(vh*sampfreq,pre,at,post); 
CUT.PX(:,:,1)=cut(P(:,1),pre,at,post,'padding','nan');
CUT.PY(:,:,1)=cut(P(:,2),pre,at,post,'padding','nan');
CUT.CX(:,:,1)=cut(C(:,1),pre,at,post,'padding','nan');
CUT.CY(:,:,1)=cut(C(:,2),pre,at,post,'padding','nan');
CUT.FX(:,:,1)=cut(F(:,1),pre,at,post,'padding','nan');
CUT.FY(:,:,1)=cut(F(:,2),pre,at,post,'padding','nan');
CUT.f(:,:,1)=cut(fmag(:,1),pre,at,post,'padding','nan');
CUT.d(:,:,1)=cut(cmag(:,1),pre,at,post,'padding','nan');

% ------------------------------------------------
% Get mean direction and magnitude at initial point
%i = find(CUT.t>180 & CUT.t<200);
%D.startFX=mean(CUT.FX(i,:,1));     % Force X Left 
%D.startFY=mean(CUT.FY(i,:,1));
%D.startFXR=mean(CUT.FX(i,:,2));
%D.startFYR= mean(CUT.FY(i,:,2));
%[D.startAngL,D.startMagL]=cart2pol(D.startFYL,D.startFXL);      % Start angle and magnitude 
%[D.startAngR,D.startMagR]=cart2pol(D.startFYR,D.startFXR);

%i=find(CUT.t==600);
%D.startBX=mean(CUT.BPosX(i,:));    % Initial Ball Position 
%D.startBY=mean(CUT.BPosY(i,:));
%[D.startAngB,D.startMagB]=cart2pol(D.startBY+50,D.startBX);      % Start angle and magnitude of Ball 

% ------------------------------------------------
% Get amount of correction after
%i=find(CUT.t>250 & CUT.BPosY<100);
%D.corrAbsFL=mean(abs(CUT.FX(i,:,1))); % Absolute value 
%D.corrAbsFR=mean(abs(CUT.FX(i,:,2)));
%D.corrDirL=mean((CUT.FX(i,:,1)));  % Signed value 
%D.corrDirR=mean((CUT.FX(i,:,2)));  % Signed value 

% interpolate RT/MT to millisecond
preRT=find(cmag(1:find(cmag==max(cmag)))<2,1,'last');
vel_preRT=diff(cmag(preRT+[0:1]))/sample; % in pix/ms
RToffset=(2-cmag(preRT))/vel_preRT; % in ms
D.corrRT=round(t(preRT)+RToffset);

preMT=find(cmag(1:find(cmag==max(cmag)))<6,1,'last');
vel_preMT=diff(cmag(preMT+[0:1]))/sample;
MToffset=(6-cmag(preMT))/vel_preMT;
D.corrMT=round(t(preMT)+MToffset-t(preRT)-RToffset);
D.corrMT_vel=round(t(preMT)+MToffset-t(at));

% ------------------------------------------------
% check for bad movement time; usually means a double reach

if D.mt > D.mtMax
  D.good = 0
end

%keyboard
i=find(vh==max(vh),1,'first');
D.maxV=max(vh)*sampfreq;
D.maxVdist=norm(P(i,:));
D.maxVtime=round(t(i));

% ------------------------------------------------
% find closest point to target
%traj=[CUT.BPosX CUT.BPosY];
%target=repmat([D.tarX D.tarY],size(traj,1),1);
%for i=1:size(traj,1)
%  dist(i)=norm(traj(i,:)-target(i,:));
%end
%[D.mindist tmin] = min(dist);

% ------------------------------------------------
% Display trial
if (fig>0)
    figure(fig);
        subplot(5,1,[1:2]);
        plot(CUT.PX,CUT.PY,'k.');
        %rectangle('Position',[-180 -180  360 360],...
        %    'Curvature',[1 1]);
        ylabel('y (mm)');xlabel('x (mm)');axis equal;
        hold on
        plot(CUT.PX(tmin),CUT.PY(tmin),'r*');
        %plot(D.tarX(1),D.tarY(1),'bo');
        %plot(D.startBX,D.startBY,'b*');
        hold off

        subplot(5,1,3);
        plot(CUT.t,CUT.d(:,1,1),'b');
        
        drawlines([0 D.rt-D.velRT+D.mtMin D.rt-D.velRT+D.mtMax],[0 0 0]);
        set(gca,'Box','off');

        subplot(5,1,4);
        plot(CUT.t,CUT.f(:,1,1),'r');%,CUT.t,CUT.f(:,1,2),'b');legend({'left','right'});
        drawlines([0 D.rt-D.velRT+D.mtMin D.rt-D.velRT+D.mtMax],[0 0 0]);
        %drawlines([0 D.rt+D.mtMin D.rt+D.mtMax],[0 0 0]);
        set(gca,'Box','off');

        subplot(5,1,5);
        plot(CUT.t,CUT.v(:,1,1),'r');%,CUT.t,CUT.v(:,1,2),'b');
        drawline(CUT.t(tmin));

        set(gcf,'Position',[0 0 400 600]);
        wysiwyg;

     hold off;
     % set(gcf,'PaperPosition',[2,2,6,20]);
     wysiwyg;
     keyboard; 
end;