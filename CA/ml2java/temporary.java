/**
 *  temporary.java engendre par ml2java 
 */


/**
 *  de'claration de la fonction myfun___1
 *    vue comme la classe : MLfun_myfun___1
 */ 
class MLfun_myfun___1 extends MLfun {

  private static int MAX = 1;

  MLfun_myfun___1() {super();}

  MLfun_myfun___1(int n) {super(n);}

  public MLvalue invoke(MLvalue MLparam){
    if (MLcounter == (MAX-1)) {
      return invoke_real(MLparam);
    }
    else {
      MLfun_myfun___1 l = new MLfun_myfun___1(MLcounter+1);l.MLaddenv(MLenv,MLparam); return l;
    }
  }


  MLvalue invoke_real(MLvalue x___2) {

    { 
      MLvalue T___3;
      { 
        MLvalue T___4;
        MLvalue T___5;
        T___4=x___2;
        T___5=0;
        T___3=MLruntime.MLequal( ()T___4,()T___5);
      }
      if (((MLbool)T___3).MLaccess())
        { 
          MLvalue T___6;
          T___6=0;
          return T___6;
        }
      else
        { 
          MLvalue T___7;
          { 
            MLvalue T___8;
            MLvalue T___9;
            T___8=temporary.myfun___1;
            { 
              MLvalue T___10;
              MLvalue T___11;
              T___10=x___2;
              T___11=1;
              T___9=MLruntime.MLsubint( ()T___10,()T___11);
            }
            T___7=T___8(T___9);
          }
          return T___7;
        }
    }
  }

}
// fin de la classe MLfun_myfun___1
/**
 * 
 */
class temporary {

  myfun___1= myfun___1(1);

public static void main(String []args) {

}}

// fin du fichier temporary.java