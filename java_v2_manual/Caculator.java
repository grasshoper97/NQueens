import java.util.concurrent.CountDownLatch;
import java.util.Arrays;
class myT extends Thread {
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
	public  myT(int tid){
		m_tid = tid;
	}
	public void run()
	{
		for (int j = m_tid + 1; j < m_N; ++j) 
		{ if (m_a[ m_tid] == m_a[j] || Math.abs( m_a[ m_tid ] - m_a[j]) == j - m_tid ) 
			m_b[ m_tid ] ++;                 // 发现互相攻击的皇后对，conflict加一
		}
		m_latch.countDown(); 
	}
}

public class Caculator 
{
	public static void main(String [] args)
	{
		int N = 8 ;
		if(args.length == 1){
			N	   		= Integer.parseInt(args[0]);
		}                                              
		else{
			System.out.printf("usage:  exename  N  \n");
			System.out.printf("e.g. :  Cal  100 \n"); 
			System.exit(0);
		}
		int queen[] = new int[ N ];
		int result[] = new int[ N ];

		for (int i = 0; i < N; ++i)
		{
			queen[i] = i;
			result[i]= 0;
		}

		final CountDownLatch latch = new CountDownLatch( N );  
		long startTime = System.nanoTime();

		for (int i = 0; i < N; ++i)
		{
			myT  tmp =  new myT( i );
			if(i == 0)
				tmp.setArr( latch,  queen , result , N );  // 设置静态变量
			tmp.start();
		}


		try {  
			latch.await();  
		} catch (InterruptedException e) {  
			e.printStackTrace();  
		} 

		// System.out.println(Arrays.toString( result ));
		long sum = 0;
		long all = (long)N*(N-1)/2;
		for (int i = 0; i < N; ++i)
			sum += result[i];

		long endTime = System.nanoTime();
		long us = ( endTime-startTime )/1000 ; 
		long ms = us/1000 ; 
		System.out.printf("N= %5d    %15d    %15d   %15d us   %15d ms %n",N,  sum, all ,us , ms ); 
	}
}
