function ANA=balloonpop_subj(subjname,fig,block,trial);
% ANA = balloonpop_subj(subjname,[fig],[block],[trial]);
%
% analyze behavior of a subject in the balloonpop experiment, 
% starting at BN=block,TN=trial
%
% if fig is supplied, will do plots

% copied from ballpush1_subj
  
if nargin<2
    fig=0;
end;

datafilename=['BPO_' subjname '.dat'];
outfilename=['BPO_' subjname '.ana'];
tracefilename=['BPO_' subjname '.mat'];
TRA=[];
ANA=[];
D=dload(datafilename);

if (nargin<3)
    s=1;
else
    if (nargin<4)
        s=find(D.BN==block & D.TN==1);
    else
        s=find(D.BN==block & D.TN==trial);
    end;
end;
trials=[s:length(D.BN)];
oldblock=-1;
for i=trials
   if (oldblock~=D.BN(i))
     % this means we're on a new block, yeah?
     if oldblock ~= -1
       if C.TN < 40
         % cursor may have jumped... kill the rest of the block
         ANA=addstruct(ANA,struct('BN',D.BN(i-1),'TN',D.TN(i-1)+1,...
                                  'good',0,'startTR',C.startTR+3, ...
                                  'startTRreal',C.startTRreal+3), ...
                       'row','force');
       end
     end         
     oldblock=D.BN(i);
     MOV=movload(['BPO_' subjname '_' num2str(D.BN(i),'%02d') '.mov']);
   end;
   fprintf('%d %d\n',D.BN(i),D.TN(i));
   if D.TN(i) < 41
     % skip that mystery 41st trial entirely
     [C,CUT]=balloonpop_trial(MOV{D.TN(i)},getrow(D,i),fig);
     % update TRA
     if D.startTR ~= D.startTRreal
       C.good=0;
     end
     ANA=addstruct(ANA,C,'row','force');
     TRA=addstruct(TRA,CUT,'column');
   end
end;

% TRA.t=[0:sample:1500]';

if (nargin<3)
    save(tracefilename,'TRA');
    dsave(outfilename,ANA);
end;
