import sys;
import random;

def calculateCentroid(array,idx,k):
    centroids = [0]*k;
    for clusterId in xrange(k):
        sum = 0;
        count = 0;
        for i in xrange(len(array)):
            if (idx[i] == clusterId):
                sum += array[i];
                count+=1;
        if count > 0:
            centroids[clusterId] =  float(sum)/count;
        else:
            centroids[clusterId] =  0;
    return centroids;

def distance(a,b):
    return pow(a - b,2)

def updateCluster(array,idx,centroids):
    k = len(centroids)
    # cluster_dist = [0] * k;
    # cluster_num = [0] * k;
    # mean_cluster_dist =[0] *k;

    for i in xrange(len(array)):
        (idx[i],dist) = updateElement(array[i],centroids);
    #     cluster_dist[idx[i]] += dist;
    #     cluster_num[idx[i]] +=1;
    # for m in xrange(k):
    #     if cluster_num[m] > 0:
    #         mean_cluster_dist[m] = cluster_dist[m]/cluster_num[m];
    #     else:
    #         mean_cluster_dist[m] = 0;
    # return (mean_cluster_dist,cluster_num);
    return idx;

def updateElement(number,centroids):
    min_dist = 999999999;
    min_cluster_id = 0;
    for m in xrange(len(centroids)):
        if distance(number,centroids[m]) < min_dist:
            min_cluster_id = m;
            min_dist = distance(number,centroids[m]);
    return (min_cluster_id,min_dist)

def convergence(array,idx,k):
    former_idx = idx[:];
    centroids = calculateCentroid(array,idx,k);
    idx = updateCluster(array,idx,centroids);
    centroids = calculateCentroid(array,idx,2);    
    while (1):
        idx = updateCluster(array,idx,centroids);
        centroids = calculateCentroid(array,idx,2);
        if former_idx == idx:
            break;
        former_idx = idx;    
    return (idx, centroids)

def adjustClustIdx(idx,centroids):
    if (centroids[0] > centroids[1]):
        for i in xrange(len(idx)):
            if idx[i] == 1:
                idx[i] = 0;
            else:
                idx[i] = 1;
    return idx;

def disp(idx,centroids):        
    print ','.join(map(str,idx));
    # centroids = [int(x) for x in centroids]
    # print ','.join(map(str,centroids));

def help():
    return "Usage:\npython kmeans.py k N [N...]";

def main():
    if (len(sys.argv) < 3):
        print help();
        quit(-1);

    k =  int(sys.argv[1]);
    array =  [float(x) for x in sys.argv[2:]];
    idx = [random.randint(0,k-1) for x in xrange(len(array))];
    
    (idx, centroids) = convergence(array,idx,k);

    idx = adjustClustIdx(idx,centroids)
    disp(idx,centroids)

if __name__ == '__main__':
    main();

