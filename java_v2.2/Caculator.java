import java.util.concurrent.CountDownLatch;
import java.util.Arrays;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
class Global
{
	static final int  CORES = 40;
	static  int  TASK = 0;
}


class mySum extends Thread {
	static CountDownLatch 	m_latch = null ;
	static int[] 	m_a 	= null;// 存放queen数组
	static long[]	m_b  	= null ;// 存放结果
	static int 		m_N 	= 0;
	int 			m_tid 	= -1;
	public void setArr(CountDownLatch c ,  int[] a, long[] b , int N)
	{	
		m_latch = c;
		m_a = a;
		m_b = b;
		m_N = N;
	}
	public  mySum( int tid ){
		m_tid = tid;
	}
	public void run()
	{
		m_b[ m_tid ] = 0;  //保证了数组多次运行不会累计
		for (int j = m_tid * Global.TASK; j < ( m_tid +1 )*Global.TASK ; ++j) 
			m_b[ m_tid ] += m_a[j] ;                 // 发现互相攻击的皇后对，conflict加一
		m_latch.countDown(); 
	}
}
class myConflict implements Runnable{
	static CountDownLatch 	m_latch = null ;
	static int[] 	m_a 	= null;// 存放queen数组
	static int[]	m_b  	= null ;// 存放结果
	static int 		m_N 	= 0;
	int 			m_tid 	= -1;
	public void setArr(CountDownLatch c ,  int[] a, int[] b , int N)
	{	
		m_latch = c;
		m_a = a;
		m_b = b;
		m_N = N;
	}
	public  myConflict(int tid){
		m_tid = tid;
	}
	@Override
	public void run()
	{
		m_b[ m_tid ] = 0;//保证了数组多次运行不会累计
		for (int j = m_tid + 1; j < m_N; ++j) 
		{ if (m_a[ m_tid] == m_a[j] || Math.abs( m_a[ m_tid ] - m_a[j]) == j - m_tid ) 
			m_b[ m_tid ] ++;                 // 发现互相攻击的皇后对，conflict加一
		}
		// System.out.printf("[%5d]-> %5d%n", m_tid, m_b[m_tid]);
		m_latch.countDown(); 
	}
}

public class Caculator 
{
	public static void main(String [] args)
	{
		int N = 0 ;
		int Loop = 0 ;
		if(args.length == 2){
			N	   		= Integer.parseInt(args[0]);
			Loop   		= Integer.parseInt(args[1]);
		}                                              
		else{
			System.out.printf("usage:  exename  N  Loop\n");
			System.out.printf("e.g. :  Cal  100  5 \n"); 
			System.exit(0);
		}
		int queen[] = new int[ N ];
		int result[] = new int[ N ];

		for (int i = 0; i < N; ++i) // 初始化为  i, 0； 
		{
			queen[i] = i;
			result[i]= 0;
		}

		for (int loop = 0 ; loop < Loop ; loop++){
		long startTime = System.nanoTime();
		//................................................

		final CountDownLatch con_latch = new CountDownLatch( N  );  
		ExecutorService pool = Executors.newFixedThreadPool( 30 );

		for (int i = 0; i < N; ++i)
		{
			myConflict  tmp =  new myConflict( i );
			if(i == 0)
				tmp.setArr( con_latch,  queen , result , N );  // 设置静态变量
			pool.submit( tmp );
		}
		pool.shutdown(); //等待已经提交的任务结束；
		try {  
			con_latch.await();  // 等待全部线程结束；
		} catch (InterruptedException e) {  
			e.printStackTrace();  
		} 


		// System.out.println(Arrays.toString( result ));
		final CountDownLatch sum_latch = new CountDownLatch( Global.CORES );  
		long sub_sum[] = new long[ Global.CORES ];
		long sum = 0;
		long all = (long)N*(N-1)/2;
		if( N < 1000 )
		{ // 数量太少，直接串行计算到 sum里
			for (int i = 0; i < N; ++i)
				sum += result[i];
		}
		else
		{
			Global.TASK= N / Global.CORES ;	// 由于都是 1000 的倍数，所以没有余数，简化了计算。
			// 第一步，把 arr_N 规约到  arr_CORES 中
			for (int i = 0; i < Global.CORES ; ++i) // 启动 40 个线程，来求和
			{
				mySum  tmp =  new mySum( i );
				if(i == 0)
					tmp.setArr( sum_latch,  result , sub_sum , N );  // 设置静态变量
				tmp.start();
			}
			try {  
				sum_latch.await();  // 等待全部线程结束；
			} catch (InterruptedException e) {  
				e.printStackTrace();  
			} 
			// 第二步， 把arr_COERS 规约到 sum 里
			for (int i = 0; i < Global.CORES ; ++i) 
				sum += sub_sum[i]; 
		}

		//................................................
		long endTime = System.nanoTime();
		long us = ( endTime-startTime )/1000 ; 
		long ms = us/1000 ; 
		System.out.printf("[%4d] N= %5d    %15d    %15d   %15d us   %15d ms %n", loop, N,  sum, all ,us , ms ); 
		}// for loop
	}//main()
}//Caculator class
