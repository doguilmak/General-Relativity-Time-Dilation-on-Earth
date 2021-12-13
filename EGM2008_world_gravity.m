clc;
clear;
format long

% Reference
% http://hyperphysics.phy-astr.gsu.edu/hbase/Relativ/gratim.html#c5 
% https://en.wikipedia.org/wiki/Femtosecond
% http://icgem.gfz-potsdam.de/calcgrid

egmdatnum = importdata('EGM2008_world_gravity.gdf',' ',34);
egmdat = egmdatnum.textdata;
egmnum = egmdatnum.data;
la=egmnum(:, 1);
fi=egmnum(:, 2);
R=egmnum(:, 3);

c=299792458; % m/s
R=R+6371E3; % m
dat1=egmnum(:, 4); % mGal
dat1=dat1/1E5; % mGal -> m/s2

% Calculating Time Dilation

## A femtosecond is the SI unit of time equal to 10-15 or 
## 1/1 000 000 000 000 000 of a second; that is, one quadrillionth,
## or one millionth of one billionth, of a second.
m=length(dat1);
t_dil=zeros(m, 1);
k = 1:m;
  t_dil(k)=((1/sqrt((1-((2*dat1(k).*R(k))/c^2))))*1E15)-15389587415.8; % s -> fs

lamin=min(la);
lamax=max(la);
fimin=min(fi);
fimax=max(fi);
la1=la(1);
la2=la(2);

i=0;
while la1==la2 
  i=i+1; 
  la2=la(2+i);
end 

fi1=fi(1);
fi2=fi(2);
j=0;
while fi1==fi2
  j=j+1;
  fi2=fi(2+j);
end

dla=abs(la1-la2);
dfi=abs(fi1-fi2);
frows=abs(floor((fimax-fimin)/dfi+1.5));
lcols=abs(floor((lamax-lamin)/dla+1.5));
n=1;
for i=frows:-1:1
  for j=1:lcols
    if n <= length(la) 
      if la(n) < 180
        X(i,j)=la(n);
      else
        X(i,j)=la(n)-360;
      end
    Y(i,j)=fi(n);
    Z(i,j) = t_dil(n);
    n=n+1;
    end
  end    
end

dat_max=max(t_dil);
dat_min=min(t_dil);
div=(dat_max-dat_min)/100;
[c,h]=contourf(X, Y, Z, dat_min:div:dat_max);
clabel(c,h);
hold on

colorbar
h = colorbar;
ylabel(h, '1 fs(femtosecond) - 15389587415.8 ');

ylabel('Latitude')
xlabel('Longitude')

bfid = fopen('world.bln');

while feof(bfid)==0;
    
    n = fscanf(bfid,'%i,%i',2);
    if isempty(n)==1;
      break
    end
    fila = fscanf(bfid,'%g,%g',[2 n(1)]);
    if n(1)~=length(fila(1,:));
      fila = fscanf(bfid,'%g %g',[2 n(1)]);
    end
    la=fila(1,:);
    fi=fila(2,:);
    plot(la, fi, 'Color', 'white', 'LineWidth', 1);
    hold on

end
