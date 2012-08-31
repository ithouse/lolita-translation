$(function(){
  $(".tab-language-switch li").live("click",function(){
    $(".tab-language-switch li").removeClass("active");
    $(this).addClass("active");
    var locale = $(this).data("locale");
    var tab_name = $(this).data("tab");
    var container = $(this).data("container") || ".tab-content";
    $(container + " .language-wrap").hide(0)
    $("#"+locale+"_for_"+tab_name).show(0)
    resize_all_tinymce_editors()
  })
})