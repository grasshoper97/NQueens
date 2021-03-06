
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ForkJoinPool;
import java.util.concurrent.Future;
import java.util.concurrent.RecursiveTask;
import java.io.FileReader;
import java.util.Scanner;

class FitnessTask extends RecursiveTask<Integer>
{
	private static final long serialVersionUID = 1L;
	//阈值
	private int threshold = 2;
	private int start;
	private int end;
	private int N;
	private int [] arr;

	public FitnessTask(int []a, int n, int start, int end, int thres)
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
		//核心计算代码；
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
			FitnessTask leftTask = new  FitnessTask(arr, N, start,middle, threshold);
			FitnessTask rightTask = new  FitnessTask(arr,N, middle+1,end, threshold);
			//执行子任务
			leftTask.fork();
			rightTask.fork();
			//等待子任务执行完，并得到执行结果
			int leftResult = leftTask.join();
			int rightResult = rightTask.join();
			//合并子任务
			sum = leftResult + rightResult;

		}
		return sum;
	}//func
} // class FitnessTask	

class Caculator
{
	public int get_conflicts( int[] f_a, int f_num, int threshold )
	{
		int conflict = 0;
		ForkJoinPool forkJoinPool = new ForkJoinPool(); // 生成任务调度池
		//								a , N ,  begin, end ,  threshold
		FitnessTask task = new FitnessTask(f_a,f_num, 0, f_num-2, threshold); //生成任务
		Future<Integer> result = forkJoinPool.submit(task);			// 提交任务
		try{
			conflict = result.get(); 	//启动线程开始计算
		}
		catch( Exception e)
		{
			System.out.println(" get result error!");
		}
		return conflict;
	}// func
}//class Caculator

public class Main{
	public static void main(String[] args)
	{
		String filename = "";  		// 数据文件名
		int repeat 		= 0;
		int [] f_a 		= null;
		int f_num 		= 0;
		int f_conflict 	= 0;
		int threshold	= 0;	
		if(args.length == 3){
			filename  = args[0];
			repeat	  = Integer.parseInt(args[1]);
			threshold = Integer.parseInt(args[2]);
			System.out.printf("file: %s  ,  repeat: %d,   ", filename, repeat);
		}                                              
		else{
			System.out.printf("usage:  exename  filename repeat thres\n");
			System.out.printf("e.g. :  Count  100.txt  10 5\n"); 
			System.exit(0);
		}
		try{
			Scanner scan = new Scanner( new FileReader( filename ) );
			f_num = scan.nextInt();
			String f_s_queen = scan.next(); // skip "queens"
			f_conflict= scan.nextInt();
			String f_s_con= scan.next();	// skip "conflicts"
			f_a=new int[ f_num ];
			for(int i =0; i< f_num ; i++){
				f_a[i]= scan.nextInt();
			}

			System.out.printf("f_num: %d,   f_con: %d  \n ", f_num, f_conflict);
			// for(int i =0; i< f_num ; i++){
			// System.out.printf("%d, ", f_a[i]);	
			//}
			System.out.println();	
		}catch (Exception e){
			System.out.println(" read file error !");	
			System.exit(0);
		}
		int processors = Runtime.getRuntime().availableProcessors();
		long time_sum = 0; 
		for(int r = 0; r< repeat ; r++) {
			long startTime = System.currentTimeMillis();
			//----------------------------------------------------------------------------
			try
			{
				Caculator  myCaculator = new Caculator();
				int m_conflict =  myCaculator.get_conflicts( f_a, f_num, threshold );
				System.out.printf(" f_conflict= %d , m_conflict= %d  ", f_conflict, m_conflict );
				if( f_conflict == m_conflict )
					System.out.printf(" check PASS! \n");
				else
					System.out.printf(" check False! \n");
			}
			catch (Exception e)
			{
				e.printStackTrace();
				System.out.printf(" exception in main! \n");
			}
			//----------------------------------------------------------------------------
			long endTime = System.currentTimeMillis();
			time_sum += (endTime-startTime);
			System.out.printf("%15s%15s%15s%n",  "processors",  "threshold", "Time(ms)"); 
			System.out.printf("%15d%15d%15d%n",  processors,  threshold, endTime-startTime); 
		}
		System.out.printf("%15s%15d%15f%n",  "average",  f_num  , 1.0f* time_sum / repeat); 

	}//main

}// class
