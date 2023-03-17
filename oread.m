function obj=oread(objf,angf)
% Mohammad Mahdi Kabiri.
% mmahdikabiri@gmail.com, m.kabiri@stu.iiees.ac.ir, mohammad.kabiri@warick.ac.uk
% This function gets an .Obj file and calculates the local thickness map
% at vertices.  
% input parameters
% objf: the address of the file (string)
% angf:  Back-face culling is defined by the angle threshold. This value 
% defines the minimum acceptable angle difference between the current 
% vertex and the faces on the other side of the mesh. 

if nargin<2
    angf=90;
end

 fid=fopen(objf,'r');
 
 va=[];
 fa=[];
 
while 1
    
  l=fgetl(fid);
  if ~isempty(l)
  switch l(1)
      case 'v'
          va(end+1,:)=sscanf(l,'v %f %f %f\n');
      case 'f'
          fa(end+1,:)=sscanf(l,'f %d %d %d\n');
  end
  end
    if l==-1
        break;
    end
  
end

fclose(fid);
 
 TR=triangulation(fa,va);
 vn = vertexNormal(TR);
 
plp=[];
pln=[];

for i=1:size(fa,1)   
    x=va(fa(i,:),1);
    y=va(fa(i,:),2);
    z=va(fa(i,:),3);
      p= pcfitplane(pointCloud([x,y,z]),1e-3);
   plp(end+1,:)=p.Parameters;
   pln(end+1,:)=p.Normal;   
end


  D=plp*padarray(va',1,1,'post')./rssq(plp(:,1:3),2);
  angb=acosd(pln*vn'./(rssq(pln,2)*rssq(vn')));
  D(angb<=angf)=10*max(D(:)); % 10 times the max value is a ad-hoc parameter to elimitate the mesh noise 
  th=min(D)';
   

  obj.v=va;
  obj.f=fa;
%   obj.planep=plp;
%   obj.normal=pln;
  obj.th=th;
  obj.vn=vn;
   obj.Tri=TR;

 
  
  
  
  
  