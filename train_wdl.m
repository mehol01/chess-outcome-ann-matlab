clear; clc; 

oversampleRatio = 0.20;   
hiddenLayerSize = 100;


T = readtable('features1.csv');

featureNames = {'elo_diff','material_diff_last','ply_count'};
X = [T.elo_diff, T.material_diff_last, T.ply_count]';

classIdx = ones(height(T),1);
classIdx(T.outcome == 0) = 2;
classIdx(T.outcome == -1) = 3;
classNames = {'White win','Draw','Black win'};

Y = zeros(3, height(T));
for c = 1:3
    Y(c, classIdx == c) = 1;
end

rng(1);
N = size(X,2);
idx = randperm(N);
splitPoint = round(0.8*N);
trainIdx = idx(1:splitPoint);
testIdx = idx(splitPoint+1:end);

Xtrain = X(:,trainIdx); Ytrain = Y(:,trainIdx);
Xtest = X(:,testIdx);   Ytest = Y(:,testIdx);
classTrain = classIdx(trainIdx);
classTest = classIdx(testIdx);

[Xtrainn, xs] = mapminmax(Xtrain);
Xtestn = mapminmax('apply', Xtest, xs);

drawIdx = find(Ytrain(2,:) == 1);
notDrawIdx = find(Ytrain(2,:) == 0);
targetDrawCount = round(oversampleRatio/(1-oversampleRatio) * length(notDrawIdx));
nReplicate = max(1, round(targetDrawCount/length(drawIdx)));

rng(10);
repIdx = repmat(drawIdx, 1, nReplicate);
Xbal = [Xtrainn(:,notDrawIdx), Xtrainn(:,repIdx)];
Ybal = [Ytrain(:,notDrawIdx), Ytrain(:,repIdx)];
shuffleIdx = randperm(size(Xbal,2));
Xbal = Xbal(:,shuffleIdx);
Ybal = Ybal(:,shuffleIdx);

net = patternnet(hiddenLayerSize);
net.divideParam.trainRatio = 0.85;
net.divideParam.valRatio = 0.15;
net.divideParam.testRatio = 0;

[net, tr] = train(net, Xbal, Ybal);

predTest = net(Xtestn);
[~, predClass] = max(predTest, [], 1);
predClass = predClass';

accuracy = mean(predClass == classTest);
fprintf('Test accuracy: %.2f%%\n', accuracy*100);

confMat = confusionmat(classTest, predClass);
fprintf('\nConfusion matrix (rows=true, cols=pred):\n');
disp(array2table(confMat, 'VariableNames', classNames, 'RowNames', classNames));

fprintf('\nPer class precision/recall:\n');
for c = 1:3
    tp = confMat(c,c);
    fp = sum(confMat(:,c)) - tp;
    fn = sum(confMat(c,:)) - tp;
    precision = tp / (tp+fp);
    recall = tp / (tp+fn);
    fprintf('%s -> precision: %.2f%%, recall: %.2f%%\n', classNames{c}, precision*100, recall*100);
end

figure;
trueLabels = categorical(classNames(classTest), classNames);
predLabels = categorical(classNames(predClass), classNames);
confusionchart(trueLabels, predLabels, ...
    'Title', 'ANN - Test Confusion Matrix');

Xelo_train = [T.elo_diff(trainIdx), T.avg_elo(trainIdx)];
Xelo_test  = [T.elo_diff(testIdx),  T.avg_elo(testIdx)];

B = mnrfit(Xelo_train, classTrain);
probsBaseline = mnrval(B, Xelo_test);
[~, predClassBaseline] = max(probsBaseline, [], 2);

accuracyBaseline = mean(predClassBaseline == classTest);
fprintf('\n Classical baseline (Elo-only multinomial logistic regression) \n');
fprintf('Baseline accuracy: %.2f%%\n', accuracyBaseline*100);
fprintf('ANN accuracy:      %.2f%%\n', accuracy*100);
fprintf('Improvement:       %+.2f pp\n', (accuracy-accuracyBaseline)*100);

nFeatures = size(Xtestn,1);
importance = zeros(nFeatures,1);
rng(42);
for f = 1:nFeatures
    Xperm = Xtestn;
    Xperm(f,:) = Xperm(f, randperm(size(Xperm,2)));
    predPerm = net(Xperm);
    [~, predClassPerm] = max(predPerm, [], 1);
    accPerm = mean(predClassPerm' == classTest);
    importance(f) = accuracy - accPerm;
end

fprintf('\nPermutation feature importance (accuracy drop when shuffled):\n');
for f = 1:nFeatures
    fprintf('%s -> %.4f\n', featureNames{f}, importance(f));
end

figure;
bar(importance);
set(gca, 'XTickLabel', featureNames, 'XTick', 1:nFeatures);
ylabel('Accuracy drop when shuffled');
title('Permutation feature importance');
xtickangle(30);

save('model_wdl.mat', 'net', 'xs', 'featureNames', 'B', 'classNames');
