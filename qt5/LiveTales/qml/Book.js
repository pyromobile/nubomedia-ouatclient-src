
function create()
{
    var tOperation = {
        story:1,
        storyLanguage:2
    };

    var tPage = {
        frontCover:1,
        page:2,
        backCover:3
      };

    var mBookId = null;
    var mLanguageId = null;
    var mStory = null;
    var mStoryLanguage = null;
    var mCurrentPieceStory = 0;
    var mCurrentPage = 0;
    var mState = tPage.frontCover;

    var book= {
        load:function(bookId, languageId){
            mBookId = bookId;
            mLanguageId = languageId;
            mState = tPage.frontCover;
            _loadStory( true );
            _loadStoryLanguage( true );
        },
        onLoaded:null,
        nextPage:function(){
            mCurrentPage++;
            var pageToShow = _checkChangeImage();

            _checkState();

            return pageToShow;
        },
        prevPage:function(){
            mCurrentPage--;
            var pageToShow = _checkChangeImage();

            _checkState();

            return pageToShow;
        },
        isAtFirstPage:function(){
            return mState === tPage.frontCover;
        },
        isAtLastPage:function(){
            return mState === tPage.backCover;
        },
        requestChangeLanguage:function(languageId)
        {
            mLanguageId = languageId;
            _loadStoryLanguage( false );
        },
        goBegin:function()
        {
            mCurrentPieceStory = 0;
            mCurrentPage = 0;
            mState = tPage.frontCover;

            var pageToShow = _preparePageToShow( true );
            return pageToShow;
        }
    };
    return book;

    function _loadStory(changeImage)
    {
        var request = new XMLHttpRequest();
        var path = '../assets/tales/'+mBookId+'/story.json';

        request.open('get',path);
        request.onreadystatechange = function( event ){
            if( request.readyState === request.DONE )
            {
                var json = JSON.parse( request.responseText );
                _prepareTexts( json, tOperation.story );
                _bookReady( changeImage );
            }
        }

        request.send();
    }

    function _loadStoryLanguage(changeImage)
    {
        var request = new XMLHttpRequest();
        var path = '../assets/tales/'+mBookId+'/languages/'+mLanguageId+'.json';

        request.open('get',path);
        request.onreadystatechange = function( event ){
            if( request.readyState === request.DONE )
            {
                var json = JSON.parse( request.responseText );
                _prepareTexts( json, tOperation.storyLanguage );
                _bookReady( changeImage );
            }
        }

        request.send();
    }

    function _prepareTexts(json,type)
    {
        if( type === tOperation.story )
            mStory = json;
        else if( type === tOperation.storyLanguage )
            mStoryLanguage = json;
    }

    function _bookReady( changeImage )
    {
        if( mStory!=null && mStoryLanguage!=null )
        {
            var pageToShow = {};
            pageToShow = _preparePageToShow( changeImage );
            /*
            var textId = mStory.story[0].texts[0];
            pageToShow.text = mStoryLanguage[textId];
            pageToShow.image = mBookId+'/images/esc01.jpg';
            pageToShow.isChangeImage = true;
            */
            if( book.onLoaded !== null )
                book.onLoaded( pageToShow );
        }
    }

    function _checkChangeImage()
    {
        var MAX_PIECE_STORY = mStory.story.length - 1;
        var changeImage = false;
        mState = tPage.page;

        if( mCurrentPage >= mStory.story[mCurrentPieceStory].texts.length )
        {
            if( mCurrentPieceStory < MAX_PIECE_STORY )
            {
                mCurrentPieceStory++;
                mCurrentPage = 0;
                changeImage = true;
            }
        }
        else if( mCurrentPage < 0 )
        {
           if( mCurrentPieceStory > 0 )
           {
               mCurrentPieceStory--;
               mCurrentPage =mStory.story[mCurrentPieceStory].texts.length - 1;
               changeImage = true;
           }
        }

        return _preparePageToShow( changeImage );
    }

    function _preparePageToShow(changeImage)
    {
        var textId = mStory.story[mCurrentPieceStory].texts[mCurrentPage];
        var text = mStoryLanguage[textId];
        var imageId = mStory.story[mCurrentPieceStory].image;

        var pageToShow = {};
        pageToShow.text = text;
        pageToShow.image = mBookId+'/images/esc'+imageId+'.jpg';
        pageToShow.isChangeImage = changeImage;

        return pageToShow;
    }

    function _checkState()
    {
        var MAX_PIECE_STORY = mStory.story.length - 1;
        if( mCurrentPage == 0 && mCurrentPieceStory == 0 )
            mState = tPage.frontCover;
        else if( (mCurrentPage >= mStory.story[mCurrentPieceStory].texts.length - 1 ) && ( mCurrentPieceStory === MAX_PIECE_STORY ) )
            mState = tPage.backCover;
    }
}
