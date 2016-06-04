 a=textread('data.txt', '%f');
 j=1;
 for i=1:13
     Y(i,:)=a(j:j+16);
     j=j+17;
     x(i)=Y(i);
 end
     