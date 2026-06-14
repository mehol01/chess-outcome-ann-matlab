clear; clc;

load('model_wdl.mat', 'net', 'xs', 'featureNames', 'B', 'classNames');

T = readtable('features2.csv');

X = [T.elo_diff, T.material_diff_last, T.ply_count]';

classIdx = ones(height(T),1);
classIdx(T.outcome == 0) = 2;
classIdx(T.outcome == -1) = 3;

Y = zeros(3, height(T));
for c = 1:3
    Y(c, classIdx == c) = 1;
end

Xn = mapminmax('apply', X, xs);

predTest = net(Xn);
[~, predClass] = max(predTest, [], 1);
predClass = predClass';

accuracy = mean(predClass == classIdx);
fprintf('Out of sample test accuracy: %.2f%%\n', accuracy*100);

confMat = confusionmat(classIdx, predClass);
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
trueLabels = categorical(classNames(classIdx), classNames);
predLabels = categorical(classNames(predClass), classNames);
confusionchart(trueLabels, predLabels, ...
    'Title', 'ANN - Out of sample Confusion Matrix (Feb data)');

Xelo = [T.elo_diff, T.avg_elo];
probsBaseline = mnrval(B, Xelo);
[~, predClassBaseline] = max(probsBaseline, [], 2);

accuracyBaseline = mean(predClassBaseline == classIdx);
fprintf('\n Classical baseline (Elo-only multinomial logistic regression) \n');
fprintf('Baseline accuracy: %.2f%%\n', accuracyBaseline*100);
fprintf('ANN accuracy:      %.2f%%\n', accuracy*100);
fprintf('Improvement:       %+.2f pp\n', (accuracy-accuracyBaseline)*100);
