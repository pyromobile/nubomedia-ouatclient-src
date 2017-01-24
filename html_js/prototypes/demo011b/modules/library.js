'use-strict';

import Book from './book';

let LibraryCtrl = (function(){
  return {
    getInstance:function()
    {
      if( !mInstance )
        mInstance = _createInstance();

      return mInstance;
    }
  };
})();

export default LibraryCtrl;

//------------------------------------------------------------------------------
// Private section
//------------------------------------------------------------------------------
let mInstance = null;
let mBooks = {};

function _createInstance()
{
  _loadBooksFromDecive();

  return {
    getBooks:function( langId )
    {
      return _getBooks( langId );
    },
    getBook:function( langId, bookId, isHD )
    {
      return _getBook( langId, bookId, isHD );
    }
  };
}

function _loadBooksFromDecive()
{
  //Temp.
  mBooks = {
    "1":{
      "id":"1",
      "title":"title",
      "cover":"",
      "langs":{
        "en":{
          "title":"The three little pigs"
        },
        "es":{
          "title":"Los tres cerditos"
        }
      }
    },
    "CR":{
      "id":"CR",
      "title":"title",
      "cover":"",
      "langs":{
        "en":{
          "title":"Little red riding hood"
        },
        "es":{
          "title":"Caperucita roja"
        }
      }
    },
    "RdO":{
      "id":"RdO",
      "title":"title",
      "cover":"",
      "langs":{
        "en":{
          "title":"The story of the three bears"
        },
        "es":{
          "title":"Ricitos de oro"
        }
      }
    }
  };
}

function _getBooks( langId )
{
  let booksTmp = [];
  for(let bookId in mBooks )
  {
    let book ={};
    book.id =  mBooks[bookId].id;
    book.title = mBooks[bookId].langs[langId].title;
    book.cover = mBooks[bookId].cover;
    booksTmp.push( book );
  }

  return booksTmp;
}

function _getBook( bookId, langId, isHD )
{
  return new Book( bookId, langId, isHD );
}
