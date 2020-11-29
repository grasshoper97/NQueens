
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ForkJoinPool;
import java.util.concurrent.Future;
import java.util.concurrent.RecursiveTask;
import java.io.FileReader;
import java.util.Scanner;

public class CountTask extends RecursiveTask<Integer>
{
	private static final long serialVersionUID = 1L;
	//阈值
	private int threshold = 2;
	private int start;
	private int end;
	private int N;
	private int [] arr;

	public CountTask(int []a, int n, int start, int end, int thres)
	{
		this.start = start;
		this.end   = end;
		this.arr   = a;
		this.N	   = n;
		this.threshold = thres;
	}

	@Override
	protected Integer compute()
	{
		int sum = 0;
		//判断任务是否足够小
		boolean canCompute = (end - start) <= threshold;
		if(canCompute)
		{
			//如果小于阈值，就进行运算
			for(int i=start; i<=end; i++)
				for(int j = i+1; j<N ; j++)
					if ( arr[i] == arr [j] || Math.abs( arr [j] - arr [i] )==j-i)
						sum ++;
		}
		else
		{
			//如果大于阈值，就再进行任务拆分
			int middle = (start + end)/2;
			CountTask leftTask = new  CountTask(arr, N, start,middle, threshold);
			CountTask rightTask = new  CountTask(arr,N, middle+1,end, threshold);
			//执行子任务
			leftTask.fork();
			rightTask.fork();
			//等待子任务执行完，并得到执行结果
			int leftResult = leftTask.join();
			int rightResult = rightTask.join();
			//合并子任务
			sum = leftResult + rightResult;
			// 释放 new 的对象 !!! 重要，否则计算300个数组后会内存溢出！！！
			leftTask = null;
			rightTask =null;
			 // System.gc();

		}
		return sum;
	}

	public static void main(String[] args)
	{
		int N 			= 100;
		int repeat 		= 40000;
		int threshold	= 2;	
		if(args.length == 3){
			N	   		= Integer.parseInt(args[0]);
			repeat 		= Integer.parseInt(args[1]);
			threshold	= Integer.parseInt(args[2]);
			System.out.printf("N: %d  ,  repeat: %d, threshold: %d \n ", N,  repeat, threshold);
		}                                              
		else{
			System.out.printf("usage:  exename  N  repeat thres\n");
			System.out.printf("e.g. :  Count  100  10 5\n"); 
			System.exit(0);
		}
		int processors = Runtime.getRuntime().availableProcessors();
		long time_sum = 0; 
		int []b = new int[ N ];		
		for(int i =0 ; i< N  ; i++)
			b[i] = i;
		for(int r = 0; r< repeat ; r++) {
			long startTime = System.currentTimeMillis();                                                                                                     
			//----------------------------------------------------------------------------
			ForkJoinPool forkJoinPool = new ForkJoinPool();
			CountTask task = new CountTask(  b,  N , 0, N-2, threshold);
			//执行一个任务
			Future<Integer> result = forkJoinPool.submit(task);
			try
			{
				int m_conflict = result.get();
				System.out.printf(" loop = %d , m_conflict= %d  ", r , m_conflict );
				if( N*(N-1)/2  == m_conflict )
					System.out.printf(" check PASS! ");
				else
					System.out.printf(" check False! ");
			}
			catch (InterruptedException e)
			{
				e.printStackTrace();
			}
			catch (ExecutionException e)
			{
				e.printStackTrace();
			}
			//----------------------------------------------------------------------------
			long endTime = System.currentTimeMillis();
			time_sum += (endTime-startTime);
			// System.out.printf("%15s%15s%15s%n",  "processors",  "threshold", "Time(ms)"); 
			// System.out.printf("%15d%15d%15d ms %n",  processors,  threshold, endTime-startTime); 
			System.out.printf("%15d ms %n",  endTime-startTime); 

			forkJoinPool = null;
			task = null;
			System.gc();
		}
		System.out.printf("%15s%15d%15f%n",  "average",  100  , 1.0f* time_sum / repeat); 

	}//main

}// class
