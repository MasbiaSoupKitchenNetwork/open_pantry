export default function(channel){
  const intFromFindClass = (parent, className) => parseInt(parent.find(className).html(), 10)
  const getMaxAllowed    = (row) => parseInt(row.data('max-allowed'), 10)
  const getStockQuantity = (row) => parseInt(row.data('stock-available'), 10)
  const getAvailable     = (row) => intFromFindClass(row, '.js-available-quantity')
  const getQuantity      = (row) => intFromFindClass(row, '.js-current-quantity')
  const getCost          = (row) => intFromFindClass(row, '.js-credit-cost')
  const getCredits       = (row) => intFromFindClass(row.parents('.js-stock-type'), '.js-credit-count')
  const getType          = (row) => row.parents('.js-stock-type').find('.js-credit-count').data('credit-type')
  const setStockQuantity = (row, newQuantity) => row.data('stock-available', newQuantity)
  const setUserQuantity  = (row, newQuantity) => row.find('.js-current-quantity').html(newQuantity)
  const setTotalQuantity = (row, newQuantity) => row.find('.js-available-quantity').html(newQuantity)
  const setCredits       = (row, newQuantity) => row.parents('.js-stock-type').find('.js-credit-count').html(newQuantity)
  const getCreditGroup   = (creditTypeName) => $(`*[data-credit-group="${creditTypeName}"]`)
  const updateQuantities = (creditGroupId, $updateRow, availableStockQuantity) => {
    $(getCreditGroup(creditGroupId)).find('.js-stock-row').toArray().forEach(row => {
      const $row = $(row);
      const [cost, credits, maxAllowed] = [getCost($row), getCredits($row), getMaxAllowed($row)];
      const affordAmount = Math.floor(credits / cost);
      if ($updateRow && $row.data('stock-id') === $updateRow.data('stock-id')){
        setStockQuantity($row, availableStockQuantity)
      }
      const rowStockQuantity = getStockQuantity($row);
      setTotalQuantity($row, _.min([affordAmount, maxAllowed, rowStockQuantity]));
    })
  }
  var fn;
  let handlers = {
    "js-add-stock": function(row){
      const credits = getCredits(row);
      const cost    = getCost(row);
      if (getAvailable(row) > 0 && credits >= cost) {
        channel.push('request_stock', { id: row.data('stock-id'), quantity: 1, type: getType(row) });
        setUserQuantity(row, getQuantity(row) + 1);
        setCredits(row, credits - cost);
      }
      if (getAvailable(row) == 0) {
        $(row).find(".js-add-stock").prop("disabled",true)
        window.plus_button =  $(row).find(".js-add-stock").html();
        $(row).find(".js-add-stock").text(row.data("max-allowed-message"))
      }
    },
    "js-remove-stock": function(row){
      const currentQuantity = getQuantity(row)
      if (currentQuantity > 0) {
        const credits = getCredits(row);
        const cost    = getCost(row);
        channel.push('release_stock', { id: row.data('stock-id'), quantity: 1, type: getType(row) });
        setUserQuantity(row, currentQuantity - 1);
        setCredits(row, credits + cost);
        setTimeout(function(){
          if (getAvailable(row) > 0) {
            $(row).find(".js-add-stock").prop("disabled",false)
            $(row).find(".js-add-stock").html(window.plus_button)
          }
        }, 100)
      }
    },
    "js-clear-stock": function(row){
      const currentQuantity = getQuantity(row)
      if (currentQuantity > 0) {
        const credits = getCredits(row);
        const cost    = getCost(row);
        channel.push('release_stock', { id: row.data('stock-id'), quantity: getQuantity(row), type: getType(row) });
        setUserQuantity(row, 0)
        setCredits(row, credits + cost * currentQuantity);
      }
    }
  }


  $('.js-stock-row').on('click', function(el){
    if (el.target && el.target.classList && typeof(el.target.classList.forEach) == 'function') { // weirdness with PhantomJS
      el.target.classList.forEach(function(className){
        fn = handlers[className]
        if (fn){
          fn($(el.currentTarget));
        };
      })
    }
  })

  $('.js-add-cart').on('click', function(el){
    el.target.classList.add("hidden")
    $(el.target).parent().find(".js-quantity-control").removeClass("hidden")
  })

  channel.on('current_credits', payload => {
    $.each(payload, (type, credits) => $(`.js-${type}-credit-count`).find('.js-credit-count').html(credits) )
  });

  channel.on('order_update', payload => {
    $('.js-user-orders').prepend(payload.html)
  });

  channel.on('update_distribution', payload => {
    const {id, html} = payload;
    const $html = $(html)
    const existing = $('.js-cart').find(`*[data-stock-distribution-id="${id}"]`).first();
    const quantity = intFromFindClass($html, '.js-quantity-requested')

    if (existing.length && quantity > 0) {
      $(existing).html($html.html())
    } else if (existing.length && quantity == 0) {
      $(existing).remove()
    } else {
      $('.js-cart').find('.js-stock-list').append(html)
    }
  });

  channel.on('set_stock', function(payload){
    const {id, quantity} = payload;
    const $row = $(`*[data-stock-id="${id}"]`);
    updateQuantities(getType($row), $row, quantity)
  });
  //initialize quantities for all credit types
  $('.js-credit-type').toArray().map(el => $(el).text()).forEach(stockType => updateQuantities(stockType))
}
