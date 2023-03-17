

 
 
 [fi,di]=uigetfile('*.obj');
obj=oread([di,fi])


figure(3655)
cla
hold on
s=trisurf(obj.f,obj.v(:,1),obj.v(:,2),obj.v(:,3),'FaceColor','interp','EdgeColor','k')
s.CData=abs(obj.th);
quiver3(obj.v(:,1),obj.v(:,2),obj.v(:,3), ...
     obj.vn(:,1),obj.vn(:,2),obj.vn(:,3),0.5,'Color','b');
material metal
colormap jet
c=colorbar
c.Label.String = 'thickness';
axis equal
view(45,45)
grid on

