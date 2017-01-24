import Book from './book';

function TaleController()
{
  return {
    create:function( configuration )
    {
      _setConfig( configuration );
    },
    getInstance:function(){
      if( !mInstance )
        mInstance = new TaleController();

      return mInstance;
    },
    prevPage:function(){
      _prevPage();
    },
    nextPage:function(){
      _nextPage();
    },
    nextPage:function(){
      _nextPage();
    }

  };
}

let mInstance = null;
let book = null;
let mConfiguration = null;

function _setConfig( configuration )
{
  mConfiguration = configuration || {};
}

export default TaleController;
