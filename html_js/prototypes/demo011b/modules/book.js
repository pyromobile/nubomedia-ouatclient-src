function Book( id, currentLanguageId, isHD )
{
  mId = id;
  mCurrentLanguageId = currentLanguageId;
  mIsHD = isHD;

  return {
    load:function( onLoadCb ){
      mOnLoad = onLoadCb;
      _loadStory();
      _loadStoryLanguage();
    },
    changeLanguage:function( languageId ){
      mCurrentLanguageId = languageId;
      _loadStoryLanguage();
    },
    prevPage:function(){
      mCurrentPage--;
      return _checkChangeImage();
    },
    nextPage:function(){
      mCurrentPage++;
      return _checkChangeImage();
    },
    release:function(){
      _release();
    }
  };
}

//------------------------------------------------------------------------------
//Private section.
//------------------------------------------------------------------------------
const tOperation = {
  story:1,
  storyLanguage:2
};

let mId = null;
let mCurrentLanguageId = null;
let mIsHD = false;
let mStory = null;
let mStoryLanguage = null;
let mOnLoad = null;
let mImages = [];
let mImageNames = [];
let mCurrentPage = 0;
let mCurrentPieceStory = 0;

function _loadStory()
{
  let baseUrl = '';
  let xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function(){
    if( xhttp.readyState == 4 && xhttp.status == 200 )
    {
      let response = xhttp.responseText;
      response = JSON.parse( response );
      _prepareTexts( response, tOperation.story );
      _loadImages();
    }
  }
  xhttp.open('GET', baseUrl + 'stories/' + mId + '/story.json', true );
  xhttp.send();
}

function _loadStoryLanguage()
{
  let baseUrl = '';
  let xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function(){
    if( xhttp.readyState == 4 && xhttp.status == 200 )
    {
      let response = xhttp.responseText;
      response = JSON.parse( response );
      _prepareTexts( response, tOperation.storyLanguage );
    }
  }
  xhttp.open('GET', baseUrl + 'stories/' + mId + '/languages/' + mCurrentLanguageId + '.json', true );
  xhttp.send();
}

function _loadImages()
{
  let resolutionPath = ( mIsHD ) ? '/' : '/sd/';
  let imagesTotal = mStory.story.length;
  for( let i=1; i<=mStory.story.length; i++ )
  {
    let imagePath = 'stories/'+mId+'/images'+resolutionPath+'esc' + i + '.jpg';
    mImageNames.push( imagePath );
    let img = new Image();
    img.src = imagePath; //'stories/1/images/sd/L3C_esc' + i + '_compo1.jpg';
    img.onload = function(){
      imagesTotal--;
      if( imagesTotal == 0 )
        _bookReady()
    };
    mImages.push( img );
  }
}

function _prepareTexts( object, type )
{
  if( type == tOperation.story )
    mStory = object;

  if( type == tOperation.storyLanguage )
    mStoryLanguage = object;

  _bookReady();
}

function _checkChangeImage()
{
  const MAX_PIECE_STORY = mStory.story.length - 1;
  let pageToShow = {};
  if( mCurrentPage >= mStory.story[mCurrentPieceStory].texts.length )
  {
    let fadeOutImage = mStory.story[mCurrentPieceStory].image;
    mCurrentPieceStory = (mCurrentPieceStory<MAX_PIECE_STORY) ? mCurrentPieceStory + 1 : 0;
    let fadeInImage = mStory.story[mCurrentPieceStory].image;

    pageToShow.fadeOutImage = mImages[fadeOutImage];
    pageToShow.fadeInImage = mImages[fadeInImage];
    pageToShow.blurImagePath = mImageNames[fadeInImage];
    pageToShow.fadeOutImagePos = mCurrentPieceStory-1;
    pageToShow.fadeInImagePos = mCurrentPieceStory;

    mCurrentPage = 0;
  }
  else if( mCurrentPage < 0 )
  {
    let fadeOutImage = mStory.story[mCurrentPieceStory].image;
    mCurrentPieceStory = (mCurrentPieceStory<=0) ? MAX_PIECE_STORY : mCurrentPieceStory - 1;
    let fadeInImage = mStory.story[mCurrentPieceStory].image;

    pageToShow.fadeOutImage = mImages[fadeOutImage];
    pageToShow.fadeInImage = mImages[fadeInImage];
    pageToShow.blurImagePath = mImageNames[fadeInImage];
    pageToShow.fadeOutImagePos = mCurrentPieceStory-1;
    pageToShow.fadeInImagePos = mCurrentPieceStory;


    mCurrentPage = mStory.story[mCurrentPieceStory].texts.length - 1;
  }

  let textId = mStory.story[mCurrentPieceStory].texts[mCurrentPage];
  pageToShow.text = mStoryLanguage[textId];

  return pageToShow;
}

function _bookReady()
{
  if( mStory && mStoryLanguage && ( mImages.length == mStory.story.length ) )
  {
    let pageToShow = {};
    let textId = mStory.story[mCurrentPieceStory].texts[mCurrentPage];
    pageToShow.text = mStoryLanguage[textId];
    pageToShow.image = mImages[mStory.story[mCurrentPieceStory].image];
    pageToShow.blurImagePath = mImageNames[mCurrentPieceStory];
    pageToShow.storyImagesPath = mImageNames;
    pageToShow.fadeInImagePos = mCurrentPieceStory;

    if( mOnLoad )
      mOnLoad( pageToShow );
  }
}

function _release()
{
  mId = null;
  mCurrentLanguageId = null;
  mIsHD = false;
  mStory = null;
  mStoryLanguage = null;
  mOnLoad = null;
  mImages = [];
  mImageNames = [];
  mCurrentPage = 0;
  mCurrentPieceStory = 0;
}

export default Book;
