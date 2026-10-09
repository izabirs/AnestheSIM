function BIS = clampBIS(BIS)
%CLAMPBIS Limit BIS to its physical range [0, 100].

BIS = min(max(BIS, 0), 100);
end
