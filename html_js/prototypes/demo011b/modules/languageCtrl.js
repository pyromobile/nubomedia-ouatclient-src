let LanguageCtrl = (function(){
  return {
    getInstance:function()
    {
      if( !mInstance )
        mInstance = _createInstance();

      return mInstance;
    }
  };
})();

//Sortcut
export const Lang = LanguageCtrl.getInstance();

//------------------------------------------------------------------------------
// Private section
//------------------------------------------------------------------------------
let mInstance = null;
let mCurrentLanguageId = '';
let mTexts = null;

function _createInstance()
{
  return {
    changeLanguage:function( langId, onChangeLanguage )
    {
      mCurrentLanguageId = langId;
      _getLanguageById( onChangeLanguage );
    },
    trans:function( key )
    {
      return _trans( key );
    },
    getCurrentId:function()
    {
      return mCurrentLanguageId;
    }
  };
}

function _getLanguageById( onLanguageOk )
{
  let baseUrl = '';
  let xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function(){
    if( xhttp.readyState == 4 && xhttp.status == 200 )
    {
      let response = xhttp.responseText;
      mTexts = JSON.parse( response );
      if( onLanguageOk )
        onLanguageOk();
    }
  }
  xhttp.open('GET', baseUrl + 'resources/languages/' + mCurrentLanguageId + '.json', true );
  xhttp.send();
}

function _trans( key )
{
  let msg = '';
  if( mTexts[key] == undefined )
    msg = '##'+key+'##';
  else
    msg = mTexts[key];

  return msg;
}

export default LanguageCtrl;
