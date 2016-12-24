%% PCA code for custering

function result = PCA(output,data, odim, batch, batch_size , gui, species)

[N, n] = size(data);
% calculating autocorrelation matrix
A = zeros(n);
me = zeros(1,n);

for i=1:n
    me(i) = mean(data(isfinite(data(:,i)),i));
    data(:,i) = data(:,i) - me(i); 
end

for i=1:n 
    for j=i:n
        c = data(:,i).*data(:,j);
        c = c(isfinite(c));
        A(i,j) = sum(c)/length(c);
        A(j,i) = A(i,j);
    end
end

% eigenvectors, sort them according to eigenvalues, and normalize
[V,S]   = eig(A);
eigval  = diag(S);
[y,ind] = sort(abs(eigval)); 
eigval  = eigval(flipud(ind));
V       = V(:,flipud(ind)); 

for i=1:odim
    V(:,i) = (V(:,i) / norm(V(:,i)));
end

% take only odim first eigenvectors
% to differentiate species
%%% 84.5 Accuracy for subspace 3 and 4 a2 == 1
%%% 85.5 Accuracy for subspace 3 and 5 a2 == 0
% to differentiate gender
%%% 91.5 Accuracy for subspace 2 and 3 a2 == 1
%%% 85.5 Accuracy for subspace 3 and 2 a2 == 0
V = [V(:,3)  V(:,2)];
D = abs(eigval)/sum(abs(eigval));
D = [D(2) ; D(3)];


% project the data using odim first eigenvectors
X = data*V;

% cluster using SOM
if gui == 0 && odim ==2
    result = SOM(output,X,batch,batch_size);
elseif gui == 1 && odim == 2
    result = SOM_GUI(output,X);
end

result = result(:,1);
figure;
plot(X(result==1,1),X(result==1,2),'r.','MarkerSize',12)
hold on
plot(X(result==0,1),X(result==0,2),'b.','MarkerSize',12)
legend('Male','Female','Centroids',...
       'Location','NW')
title 'Gender Cluster Assignments and Centroids'
hold off

figure;
plot(X(species==1 & result==1,1),X(species==1 & result==1,2),'r.','MarkerSize',12)
hold on
plot(X(species==0 & result==1,1),X(species==0 & result==1,2),'b.','MarkerSize',12)
plot(X(species==1 & result==0,1),X(species==1 & result==0,2),'g.','MarkerSize',12)
plot(X(species==0 & result==0,1),X(species==0 & result==0,2),'c.','MarkerSize',12)
legend('Species 1 Male','Species 2 Male','Species 1 Female','Species 2 Female','Centroids',...
       'Location','NW')
title 'Species+Gender Cluster Assignments and Centroids'
hold off

end