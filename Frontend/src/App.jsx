import { useEffect, useState } from 'react'
import { Link, Navigate, Route, Routes, useNavigate, useParams } from 'react-router-dom'
import './App.css'

const categories = ['Lanches', 'Pizza', 'Japonesa', 'Brasileira', 'Saudavel', 'Sobremesa']

const mockRestaurants = [
  { id: 1, name: 'Burger Prime', category: 'Lanches', eta: '25-35 min', rating: '4.8', fee: 'Gratis' },
  { id: 2, name: 'Sushi Nori', category: 'Japonesa', eta: '30-45 min', rating: '4.7', fee: 'R$ 4,99' },
  { id: 3, name: 'Forno Italia', category: 'Pizza', eta: '20-30 min', rating: '4.9', fee: 'Gratis' },
  { id: 4, name: 'Panela da Vovo', category: 'Brasileira', eta: '35-50 min', rating: '4.6', fee: 'R$ 3,99' },
]

const mockHighlights = [
  { id: 1, title: 'Combo Burger + Fritas', from: 'Burger Prime', price: 'R$ 34,90' },
  { id: 2, title: 'Temaki Salmon Especial', from: 'Sushi Nori', price: 'R$ 29,90' },
  { id: 3, title: 'Pizza Margherita Grande', from: 'Forno Italia', price: 'R$ 59,90' },
  { id: 4, title: 'Prato Executivo Frango', from: 'Panela da Vovo', price: 'R$ 27,90' },
]

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:5175'

let accessToken = null

function getAccessToken() {
  return accessToken
}

function hasAuthSession() {
  return Boolean(accessToken || localStorage.getItem('role'))
}

function clearAuthSession() {
  accessToken = null
  localStorage.removeItem('token')
  localStorage.removeItem('refreshToken')
  localStorage.removeItem('accountType')
  localStorage.removeItem('role')
}

function storeAuthSession(data, fallbackRole = 'Customer') {
  if (data?.token) {
    accessToken = data.token
    localStorage.setItem('role', resolveRoleFromToken(data.token) || fallbackRole)
  }
}

function decodeJwtPayload(token) {
  try {
    const [, payload] = token.split('.')
    if (!payload) return null
    const normalized = payload.replace(/-/g, '+').replace(/_/g, '/')
    const decoded = atob(normalized)
    return JSON.parse(decoded)
  } catch {
    return null
  }
}

function resolveRoleFromToken(token) {
  const payload = decodeJwtPayload(token)
  if (!payload) return null
  const roleClaim =
    payload['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ??
    payload.role ??
    payload.roles
  if (Array.isArray(roleClaim)) return roleClaim[0] ?? null
  return roleClaim ?? null
}

function resolveEmailFromToken(token) {
  const payload = decodeJwtPayload(token)
  if (!payload) return null
  return payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'] ?? payload.email ?? null
}

function resolveRestaurantIdFromToken(token) {
  const payload = decodeJwtPayload(token)
  if (!payload) return null
  return payload.restaurant_id ?? payload.restaurantId ?? null
}

function routeByRole(role) {
  if (role === 'DeliveryDriver') return '/entregador'
  if (role === 'RestaurantOwner') return '/restaurante'
  return '/cliente'
}

function labelToRole(label) {
  if (label === 'Entregador') return 'DeliveryDriver'
  if (label === 'Restaurante') return 'RestaurantOwner'
  return 'Customer'
}

function roleToSidebarLinks(role) {
  if (role === 'DeliveryDriver') return [{ to: '/entregador', label: 'Minhas entregas' }]
  if (role === 'RestaurantOwner') return [{ to: '/restaurante', label: 'Pedidos do restaurante' }]
  return [{ to: '/cliente', label: 'Meus pedidos' }]
}

function formatCurrency(value) {
  return `R$ ${Number(value ?? 0).toFixed(2)}`
}

function deliveryStatusLabel(status) {
  const labels = {
    0: 'Pendente',
    1: 'Atribuida',
    2: 'Coletada',
    3: 'Entregue',
    4: 'Cancelada',
    Pending: 'Pendente',
    Assigned: 'Atribuida',
    PickedUp: 'Coletada',
    Delivered: 'Entregue',
    Cancelled: 'Cancelada',
  }
  return labels[status] || String(status)
}

function orderStatusLabel(status) {
  const labels = {
    0: 'Em andamento',
    1: 'Em andamento',
    2: 'Em andamento',
    3: 'Em andamento',
    4: 'Entregue',
    5: 'Cancelado',
    Created: 'Em andamento',
    Confirmed: 'Em andamento',
    Preparing: 'Em andamento',
    OutForDelivery: 'Em andamento',
    Completed: 'Entregue',
    Cancelled: 'Cancelado',
  }
  return labels[status] || String(status)
}

function nextDeliveryStatus(status) {
  if (status === 1 || status === 'Assigned') return { value: 2, label: 'Marcar como coletada' }
  if (status === 2 || status === 'PickedUp') return { value: 3, label: 'Finalizar entrega' }
  return null
}

async function readJsonSafe(response, fallback = {}) {
  const text = await response.text()
  if (!text.trim()) return fallback
  try {
    return JSON.parse(text)
  } catch {
    return fallback
  }
}

async function refreshAuthToken() {
  const response = await fetch(`${API_BASE_URL}/api/auth/refresh-token`, {
    method: 'POST',
    credentials: 'include',
  })
  const data = await readJsonSafe(response, null)
  if (!response.ok || !data?.token) {
    clearAuthSession()
    return false
  }
  storeAuthSession(data, localStorage.getItem('role') || 'Customer')
  return true
}

async function ensureAccessToken() {
  if (getAccessToken()) return true
  return refreshAuthToken()
}

async function apiFetch(path, options = {}, allowRetry = true) {
  const url = path.startsWith('http') ? path : `${API_BASE_URL}${path}`
  const headers = new Headers(options.headers || {})
  const hasBody = options.body !== undefined && options.body !== null
  if (hasBody && !headers.has('Content-Type')) headers.set('Content-Type', 'application/json')

  const token = getAccessToken()
  if (token && !headers.has('Authorization')) headers.set('Authorization', `Bearer ${token}`)

  const response = await fetch(url, { ...options, headers, credentials: 'include' })
  if (response.status !== 401 || !allowRetry) return response

  const refreshed = await refreshAuthToken()
  if (!refreshed) {
    window.dispatchEvent(new Event('auth:expired'))
    return response
  }

  const retryHeaders = new Headers(options.headers || {})
  if (hasBody && !retryHeaders.has('Content-Type')) retryHeaders.set('Content-Type', 'application/json')
  retryHeaders.set('Authorization', `Bearer ${getAccessToken()}`)
  return fetch(url, { ...options, headers: retryHeaders, credentials: 'include' })
}

async function apiJson(path, options = {}, fallback = {}) {
  const response = await apiFetch(path, options)
  const data = await readJsonSafe(response, fallback)
  return { response, data }
}

async function addProductToCart(productId, quantity = 1, comment = '') {
  let token = getAccessToken()
  const role = localStorage.getItem('role')

  if (!token) {
    const refreshed = await ensureAccessToken()
    token = refreshed ? getAccessToken() : null
  }
  if (!token) throw new Error('Faca login para adicionar ao carrinho.')
  if (role !== 'Customer') throw new Error('Apenas contas de cliente podem adicionar ao carrinho.')

  const { response, data } = await apiJson('/api/cart/items', {
    method: 'POST',
    body: JSON.stringify({
      productId,
      quantity: Number(quantity),
      comment: comment.trim() || null,
    }),
  })
  if (!response.ok) throw new Error(data?.error || 'Nao foi possivel adicionar ao carrinho.')
  return data
}

function GlobalCart() {
  const isLoggedIn = hasAuthSession()
  const activeRole = localStorage.getItem('role') || 'Customer'
  const canUseCart = isLoggedIn && activeRole === 'Customer'
  const [isCartOpen, setIsCartOpen] = useState(false)
  const [cart, setCart] = useState(null)
  const [cartProducts, setCartProducts] = useState({})
  const [cartLoading, setCartLoading] = useState(false)
  const [cartError, setCartError] = useState('')
  const [placingOrder, setPlacingOrder] = useState(false)
  const [orderMessage, setOrderMessage] = useState('')
  const [showAddressForm, setShowAddressForm] = useState(false)
  const [savingAddress, setSavingAddress] = useState(false)
  const [addressForm, setAddressForm] = useState({
    street: '',
    number: '',
    complement: '',
    neighborhood: '',
    city: '',
    state: '',
    zipCode: '',
  })

  async function loadCart() {
    if (!canUseCart) return
    setCartLoading(true)
    setCartError('')
    try {
      const { response, data: cartData } = await apiJson('/api/cart', {}, null)
      if (!response.ok) throw new Error('Nao foi possivel carregar o carrinho.')
      const items = Array.isArray(cartData?.items) ? cartData.items : []
      const productIds = [...new Set(items.map((item) => item.productId).filter(Boolean))]
      const productEntries = await Promise.all(productIds.map(async (productId) => {
        const productResponse = await apiFetch(`/api/products/${productId}`)
        if (!productResponse.ok) return null
        const product = await readJsonSafe(productResponse, null)
        return [productId, product]
      }))
      setCart(cartData)
      setCartProducts(Object.fromEntries(productEntries.filter(Boolean)))
    } catch (loadError) {
      setCartError(loadError.message || 'Falha ao carregar carrinho.')
    } finally {
      setCartLoading(false)
    }
  }

  useEffect(() => {
    if (canUseCart) loadCart()
  }, [canUseCart])

  useEffect(() => {
    async function handleCartUpdated() {
      await loadCart()
      setIsCartOpen(true)
    }

    window.addEventListener('cart:updated', handleCartUpdated)
    return () => window.removeEventListener('cart:updated', handleCartUpdated)
  }, [canUseCart])

  const cartItems = Array.isArray(cart?.items) ? cart.items : []
  const cartCount = cartItems.reduce((total, item) => total + Number(item.quantity ?? 0), 0)
  const cartTotal = cartItems.reduce((total, item) => {
    const product = cartProducts[item.productId]
    const unitPrice = product ? Number(product.promotionalPrice ?? product.price ?? 0) : 0
    return total + unitPrice * Number(item.quantity ?? 0)
  }, 0)

  async function handlePlaceOrder() {
    setPlacingOrder(true)
    setOrderMessage('')
    try {
      const { response, data } = await apiJson('/api/orders', {
        method: 'POST',
        body: JSON.stringify(null),
      })
      if (!response.ok) throw new Error(data?.error || 'Nao foi possivel finalizar o pedido.')

      setOrderMessage('Pedido criado com sucesso.')
      setShowAddressForm(false)
      window.dispatchEvent(new Event('orders:updated'))
      await loadCart()
    } catch (orderError) {
      const message = orderError.message || 'Falha ao finalizar o pedido.'
      setOrderMessage(message)
      setShowAddressForm(message.toLowerCase().includes('endereco'))
    } finally {
      setPlacingOrder(false)
    }
  }

  async function handleSaveAddressAndPlaceOrder(event) {
    event.preventDefault()
    setSavingAddress(true)
    setOrderMessage('')
    try {
      const payload = {
        street: addressForm.street.trim(),
        number: addressForm.number.trim(),
        complement: addressForm.complement.trim() || null,
        neighborhood: addressForm.neighborhood.trim(),
        city: addressForm.city.trim(),
        state: addressForm.state.trim().toUpperCase(),
        zipCode: addressForm.zipCode.trim(),
        isDefault: true,
      }

      const { response, data } = await apiJson('/api/customers/addresses', {
        method: 'POST',
        body: JSON.stringify(payload),
      })
      if (!response.ok) throw new Error(data?.error || 'Nao foi possivel salvar o endereco.')

      setShowAddressForm(false)
      await handlePlaceOrder()
    } catch (addressError) {
      setOrderMessage(addressError.message || 'Falha ao salvar o endereco.')
    } finally {
      setSavingAddress(false)
    }
  }

  return (
    <>
      <button
        type="button"
        className={`cart-fab ${isCartOpen ? 'is-open' : ''}`}
        onClick={() => {
          setIsCartOpen((open) => !open)
          if (!isCartOpen) loadCart()
        }}
        aria-label="Abrir carrinho"
      >
        <img className="cart-fab-icon icon-img" src="/uploads/icons/cart.svg" alt="" aria-hidden="true" />
        {cartCount > 0 && <span className="cart-fab-count">{cartCount}</span>}
      </button>

      <aside className={`bottom-cart ${isCartOpen ? 'open' : ''}`} aria-label="Carrinho">
        <div className="bottom-cart-header">
          <div>
            <h3>Carrinho</h3>
            <p>{cartCount > 0 ? `${cartCount} item(ns) no pedido` : 'Seu pedido aparece aqui'}</p>
          </div>
          <button type="button" className="cart-collapse-btn" onClick={() => setIsCartOpen(false)} aria-label="Recolher carrinho"><img className="icon-img" src="/uploads/icons/chevron-down.svg" alt="" aria-hidden="true" /></button>
        </div>

        <div className="bottom-cart-body">
          {!isLoggedIn ? (
            <div className="cart-empty-state">
              <p>Entre como cliente para montar seu pedido.</p>
              <Link to="/login" className="cart-login-link">Entrar</Link>
            </div>
          ) : activeRole !== 'Customer' ? (
            <div className="cart-empty-state">
              <p>O carrinho esta disponivel para contas de cliente.</p>
            </div>
          ) : cartLoading ? (
            <p className="cart-status">Carregando carrinho...</p>
          ) : cartError ? (
            <p className="cart-status error">{cartError}</p>
          ) : cartItems.length === 0 ? (
            <div className="cart-empty-state">
              <p>Nenhum item adicionado ainda.</p>
            </div>
          ) : (
            <>
              <div className="bottom-cart-items">
                {cartItems.map((item) => {
                  const product = cartProducts[item.productId]
                  const unitPrice = product ? Number(product.promotionalPrice ?? product.price ?? 0) : 0
                  return (
                    <article className="bottom-cart-item" key={item.id}>
                      <div>
                        <h4>{product?.name || 'Produto'}</h4>
                        {item.comment && <p>{item.comment}</p>}
                      </div>
                      <strong>{item.quantity}x {formatCurrency(unitPrice)}</strong>
                    </article>
                  )
                })}
              </div>
              <div className="bottom-cart-total">
                <span>Total</span>
                <strong>{formatCurrency(cartTotal)}</strong>
              </div>
              <div className="bottom-cart-checkout">
                <button type="button" className="checkout-btn" onClick={handlePlaceOrder} disabled={placingOrder || cartItems.length === 0}>
                  {placingOrder ? 'Finalizando...' : 'Finalizar pedido'}
                </button>
                {orderMessage && <p className="cart-order-message">{orderMessage}</p>}
                {showAddressForm && (
                  <form className="cart-address-form" onSubmit={handleSaveAddressAndPlaceOrder}>
                    <h4>Endereco de entrega</h4>
                    <input required value={addressForm.street} onChange={(event) => setAddressForm((current) => ({ ...current, street: event.target.value }))} placeholder="Rua" />
                    <div className="cart-address-row">
                      <input required value={addressForm.number} onChange={(event) => setAddressForm((current) => ({ ...current, number: event.target.value }))} placeholder="Numero" />
                      <input maxLength="2" required value={addressForm.state} onChange={(event) => setAddressForm((current) => ({ ...current, state: event.target.value }))} placeholder="UF" />
                    </div>
                    <input value={addressForm.complement} onChange={(event) => setAddressForm((current) => ({ ...current, complement: event.target.value }))} placeholder="Complemento" />
                    <input required value={addressForm.neighborhood} onChange={(event) => setAddressForm((current) => ({ ...current, neighborhood: event.target.value }))} placeholder="Bairro" />
                    <div className="cart-address-row">
                      <input required value={addressForm.city} onChange={(event) => setAddressForm((current) => ({ ...current, city: event.target.value }))} placeholder="Cidade" />
                      <input required value={addressForm.zipCode} onChange={(event) => setAddressForm((current) => ({ ...current, zipCode: event.target.value }))} placeholder="CEP" />
                    </div>
                    <button type="submit" className="checkout-btn" disabled={savingAddress || placingOrder}>
                      {savingAddress ? 'Salvando...' : 'Salvar endereco e finalizar'}
                    </button>
                  </form>
                )}
              </div>
            </>
          )}
        </div>
      </aside>
    </>
  )
}

function MainPage() {
  const isLoggedIn = hasAuthSession()
  const activeRole = localStorage.getItem('role') || 'Customer'
  const sidebarLinks = roleToSidebarLinks(activeRole)
  const [isSidebarOpen, setIsSidebarOpen] = useState(false)
  const [sidebarOrders, setSidebarOrders] = useState([])
  const [sidebarOrdersLoading, setSidebarOrdersLoading] = useState(false)
  const [restaurants, setRestaurants] = useState(mockRestaurants)
  const [highlights, setHighlights] = useState(mockHighlights)

  useEffect(() => {
    function handleAuthExpired() {
      clearAuthSession()
      setIsSidebarOpen(false)
      window.location.reload()
    }

    window.addEventListener('auth:expired', handleAuthExpired)
    return () => window.removeEventListener('auth:expired', handleAuthExpired)
  }, [])

  useEffect(() => {
    let cancelled = false

    async function loadHomeData() {
      try {
        const { response: categoriesResponse, data: categoriesData } = await apiJson('/api/restaurant-categories', {}, [])
        const categoryMap = new Map((Array.isArray(categoriesData) ? categoriesData : []).map((c) => [c.id, c.name]))

        const response = await apiFetch('/api/restaurants')
        if (!response.ok) return
        const restaurantsData = await readJsonSafe(response, [])
        if (!Array.isArray(restaurantsData) || restaurantsData.length === 0 || cancelled) return

        const mappedRestaurants = restaurantsData.slice(0, 8).map((restaurant) => ({
          id: restaurant.id,
          name: restaurant.name,
          category: categoryMap.get(restaurant.categoryId) || 'Restaurante',
          eta: '25-45 min',
          rating: '4.7',
          fee: 'R$ 4,99',
          profileImageUrl: restaurant.profileImageUrl,
        }))
        setRestaurants(mappedRestaurants)

        const highlightProducts = []
        for (const restaurant of restaurantsData) {
          const productsResponse = await apiFetch(`/api/restaurants/${restaurant.id}/products`)
          if (!productsResponse.ok) continue
          const products = await readJsonSafe(productsResponse, [])
          if (!Array.isArray(products) || products.length === 0) continue

          for (const product of products) {
            highlightProducts.push({
              id: product.id,
              title: product.name,
              from: restaurant.name,
              price: `R$ ${Number(product.promotionalPrice ?? product.price ?? 0).toFixed(2)}`,
              imageUrl: product.imageUrl || '',
            })
          }
        }
        if (highlightProducts.length > 0 && !cancelled) setHighlights(highlightProducts)
      } catch {
        // fallback remains
      }
    }

    loadHomeData()
    return () => {
      cancelled = true
    }
  }, [])

  async function loadSidebarOrders() {
    if (!isLoggedIn || activeRole !== 'Customer') return
    setSidebarOrdersLoading(true)
    try {
      const { response, data } = await apiJson('/api/orders', {}, [])
      setSidebarOrders(response.ok && Array.isArray(data) ? data : [])
    } finally {
      setSidebarOrdersLoading(false)
    }
  }

  useEffect(() => {
    if (isSidebarOpen) loadSidebarOrders()
  }, [isSidebarOpen])

  useEffect(() => {
    window.addEventListener('orders:updated', loadSidebarOrders)
    return () => window.removeEventListener('orders:updated', loadSidebarOrders)
  }, [isLoggedIn, activeRole])

  async function handleLogout() {
    try {
      await apiFetch('/api/auth/logout', {
        method: 'POST',
      }, false)
    } catch {
      // Logout local deve continuar mesmo se a API estiver indisponivel.
    }
    clearAuthSession()
    setIsSidebarOpen(false)
    window.location.reload()
  }

  return (
    <main className="app-shell">
      <header className="topbar">
        <Link to="/" className="brand">IDelivery</Link>
        <div className="search-wrap">
          <input type="search" placeholder="Buscar restaurante, prato ou categoria" aria-label="Buscar" />
        </div>
        {!isLoggedIn ? (
          <Link to="/login" className="login-btn" aria-label="Entrar">
            <img className="login-icon icon-img" src="/uploads/icons/user.svg" alt="" aria-hidden="true" />
            <span>Entrar</span>
          </Link>
        ) : (
          <button type="button" className={`login-btn account-btn ${isSidebarOpen ? 'is-compact' : ''}`} onClick={() => setIsSidebarOpen((x) => !x)}>
            <img className="login-icon icon-img" src="/uploads/icons/user.svg" alt="" aria-hidden="true" />
            <span>{isSidebarOpen ? '' : 'Conta'}</span>
          </button>
        )}
      </header>

      <section className="hero-banner">
        <p className="eyebrow">Entrega rapida em minutos</p>
        <h1>Encontre seu proximo pedido sem sair da home</h1>
        <p>Descubra restaurantes perto de voce e pratos em destaque.</p>
      </section>

      <section className="chip-row" aria-label="Categorias">
        {categories.map((category) => (
          <button key={category} type="button" className="chip">{category}</button>
        ))}
      </section>

      <section className="section-block">
        <div className="section-title-row">
          <h2>Restaurantes populares</h2>
          <Link to="/cliente">Ver tudo</Link>
        </div>
        <div className="restaurant-grid">
          {restaurants.map((restaurant) => (
            <Link className="restaurant-link" to={`/restaurantes/${restaurant.id}`} key={restaurant.id}>
              <article className="restaurant-card">
                <div className="restaurant-cover">{restaurant.profileImageUrl && <img src={restaurant.profileImageUrl} alt={restaurant.name} />}</div>
                <div className="restaurant-content">
                  <h3>{restaurant.name}</h3>
                  <p>{restaurant.category}</p>
                  <small>{'\u2605'} {restaurant.rating} - {restaurant.eta} - {restaurant.fee}</small>
                </div>
              </article>
            </Link>
          ))}
        </div>
      </section>

      <section className="section-block">
        <div className="section-title-row">
          <h2>Itens em destaque</h2>
          <a href="#">Atualizar</a>
        </div>
        <div className="highlight-grid">
          {highlights.map((item) => (
            <Link className="highlight-link" to={`/produtos/${item.id}`} key={item.id}>
              <article className="highlight-card">
                <div className="thumb">
                  {item.imageUrl && <img src={item.imageUrl} alt={item.title} loading="lazy" onError={(event) => { event.currentTarget.style.display = 'none' }} />}
                </div>
                <div>
                  <h3>{item.title}</h3>
                  <p>{item.from}</p>
                  <strong>{item.price}</strong>
                </div>
              </article>
            </Link>
          ))}
        </div>
      </section>

      {isLoggedIn && (
        <>
          <button type="button" className={`sidebar-overlay ${isSidebarOpen ? 'show' : ''}`} onClick={() => setIsSidebarOpen(false)} />
          <aside className={`right-sidebar ${isSidebarOpen ? 'open' : ''}`}>
            <h3>Minha conta</h3>
            <nav className="sidebar-nav">
              {sidebarLinks.map((item) => (
                <Link key={item.to} to={item.to} onClick={() => setIsSidebarOpen(false)}>{item.label}</Link>
              ))}
            </nav>
            {activeRole === 'Customer' && (
              <section className="sidebar-orders">
                <div className="sidebar-orders-head">
                  <h4>Pedidos recentes</h4>
                  <Link to="/cliente" onClick={() => setIsSidebarOpen(false)}>Ver todos</Link>
                </div>
                {sidebarOrdersLoading ? (
                  <p>Carregando pedidos...</p>
                ) : sidebarOrders.length === 0 ? (
                  <p>Nenhum pedido encontrado.</p>
                ) : (
                  <div className="sidebar-orders-list">
                    {sidebarOrders.slice(0, 4).map((order) => (
                      <article className="sidebar-order-item" key={order.id}>
                        <span>#{String(order.id).slice(0, 8)} - {order.restaurantName || order.RestaurantName || 'Restaurante'} - {orderStatusLabel(order.status)}</span>
                        <strong>{formatCurrency(order.total)}</strong>
                      </article>
                    ))}
                  </div>
                )}
              </section>
            )}
            <button type="button" className="logout-btn" onClick={handleLogout}>Logout</button>
          </aside>
        </>
      )}

    </main>
  )
}

function RestaurantPublicPage() {
  const { id } = useParams()
  const [restaurant, setRestaurant] = useState(null)
  const [products, setProducts] = useState([])
  const [reviews, setReviews] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    let cancelled = false
    async function loadRestaurantData() {
      if (!id) return
      setLoading(true)
      setError('')
      try {
        const [restaurantRes, productsRes, reviewsRes, categoriesRes] = await Promise.all([
          apiFetch(`/api/restaurants/${id}`),
          apiFetch(`/api/restaurants/${id}/products`),
          apiFetch(`/api/restaurants/${id}/reviews`),
          apiFetch('/api/restaurant-categories'),
        ])
        if (!restaurantRes.ok) throw new Error('Restaurante nao encontrado.')

        const [restaurantData, productsData, reviewsData, categoriesData] = await Promise.all([
          readJsonSafe(restaurantRes, null),
          productsRes.ok ? readJsonSafe(productsRes, []) : Promise.resolve([]),
          reviewsRes.ok ? readJsonSafe(reviewsRes, []) : Promise.resolve([]),
          categoriesRes.ok ? readJsonSafe(categoriesRes, []) : Promise.resolve([]),
        ])

        if (cancelled) return

        const categoryMap = new Map((Array.isArray(categoriesData) ? categoriesData : []).map((c) => [c.id, c.name]))
        setRestaurant({ ...restaurantData, categoryName: categoryMap.get(restaurantData?.categoryId) || 'Restaurante' })
        setProducts(Array.isArray(productsData) ? productsData : [])
        setReviews(Array.isArray(reviewsData) ? reviewsData : [])
      } catch (e) {
        if (!cancelled) setError(e.message || 'Nao foi possivel carregar o restaurante.')
      } finally {
        if (!cancelled) setLoading(false)
      }
    }

    loadRestaurantData()
    return () => {
      cancelled = true
    }
  }, [id])

  if (loading) return <main className="page section"><p>Carregando restaurante...</p></main>

  if (error || !restaurant) {
    return (
      <main className="page section">
        <Link className="back-link" to="/">Voltar ao inicio</Link>
        <p className="form-feedback error">{error || 'Restaurante indisponivel.'}</p>
      </main>
    )
  }

  return (
    <main className="page section">
      <header className="section-header restaurant-public-header">
        <Link className="back-link" to="/">Voltar ao inicio</Link>
        <div className="restaurant-profile-row">
          <div className="restaurant-profile-photo">{restaurant.profileImageUrl ? <img src={restaurant.profileImageUrl} alt={restaurant.name} /> : <span>{restaurant.name?.slice(0, 1)}</span>}</div>
          <div>
            <h1>{restaurant.name}</h1>
            <p>{restaurant.description}</p>
          </div>
        </div>
      </header>

      <section className="stats-grid">
        <article className="stat-card"><strong>{restaurant.categoryName}</strong><span>Categoria</span></article>
        <article className="stat-card"><strong>{restaurant.isOpen ? 'Aberto' : 'Fechado'}</strong><span>Status</span></article>
        <article className="stat-card"><strong>{products.length}</strong><span>Itens no cardapio</span></article>
      </section>

      <section className="menu-editor-grid">
        <article className="menu-editor-card">
          <h2>Cardapio</h2>
          {products.length === 0 ? (
            <p className="empty-products">Nenhum item cadastrado.</p>
          ) : (
            <div className="product-list">
              {products.map((product) => (
                <Link className="product-link" to={`/produtos/${product.id}`} key={product.id}>
                  <div className="product-item">
                    <strong>{product.name}</strong>
                    <span>{product.description}</span>
                    <small>R$ {Number(product.promotionalPrice ?? product.price ?? 0).toFixed(2)} | {product.isAvailable ? 'Disponivel' : 'Indisponivel'}</small>
                  </div>
                </Link>
              ))}
            </div>
          )}
        </article>
      </section>

      <section className="section-block">
        <article className="menu-editor-card">
          <h2>Avaliacoes</h2>
          {reviews.length === 0 ? (
            <p className="empty-products">Este restaurante ainda nao possui avaliacoes.</p>
          ) : (
            <div className="product-list">
              {reviews.map((review) => (
                <div className="product-item" key={review.id}>
                  <strong>? {review.rating}/5</strong>
                  <span>{review.comment}</span>
                </div>
              ))}
            </div>
          )}
        </article>
      </section>
    </main>
  )
}

function ProductPublicPage() {
  const { id } = useParams()
  const [product, setProduct] = useState(null)
  const [restaurant, setRestaurant] = useState(null)
  const [quantity, setQuantity] = useState(1)
  const [comment, setComment] = useState('')
  const [adding, setAdding] = useState(false)
  const [clearingCart, setClearingCart] = useState(false)
  const [showClearCartPrompt, setShowClearCartPrompt] = useState(false)
  const [cartMessage, setCartMessage] = useState('')
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    let cancelled = false
    async function loadProductData() {
      if (!id) return
      setLoading(true)
      setError('')
      try {
        const productRes = await apiFetch(`/api/products/${id}`)
        if (!productRes.ok) throw new Error('Produto nao encontrado.')
        const productData = await readJsonSafe(productRes, null)

        let restaurantData = null
        if (productData?.restaurantId) {
          const restaurantRes = await apiFetch(`/api/restaurants/${productData.restaurantId}`)
          if (restaurantRes.ok) restaurantData = await readJsonSafe(restaurantRes, null)
        }

        if (cancelled) return
        setProduct(productData)
        setRestaurant(restaurantData)
      } catch (loadError) {
        if (!cancelled) setError(loadError.message || 'Nao foi possivel carregar o produto.')
      } finally {
        if (!cancelled) setLoading(false)
      }
    }

    loadProductData()
    return () => {
      cancelled = true
    }
  }, [id])

  if (loading) return <main className="page section"><p>Carregando produto...</p></main>

  if (error || !product) {
    return (
      <main className="page section">
        <Link className="back-link" to="/">Voltar ao inicio</Link>
        <p className="form-feedback error">{error || 'Produto indisponivel.'}</p>
      </main>
    )
  }

  async function handleAddToCart() {
    setCartMessage('')
    setShowClearCartPrompt(false)
    setAdding(true)
    try {
      await addProductToCart(product.id, quantity, comment)
      window.dispatchEvent(new Event('cart:updated'))
      setCartMessage('Produto adicionado ao carrinho com sucesso.')
    } catch (addError) {
      const message = addError.message || 'Falha ao adicionar ao carrinho.'
      setCartMessage(message)
      setShowClearCartPrompt(message.includes('carrinho ja possui itens de'))
    } finally {
      setAdding(false)
    }
  }

  async function handleClearCartAndAdd() {
    setClearingCart(true)
    setCartMessage('')
    try {
      const response = await apiFetch('/api/cart', {
        method: 'DELETE',
      })
      if (!response.ok) {
        const data = await readJsonSafe(response, {})
        throw new Error(data?.error || 'Nao foi possivel esvaziar o carrinho.')
      }

      await addProductToCart(product.id, quantity, comment)
      window.dispatchEvent(new Event('cart:updated'))
      setShowClearCartPrompt(false)
      setCartMessage('Carrinho esvaziado e produto adicionado com sucesso.')
    } catch (clearError) {
      setCartMessage(clearError.message || 'Falha ao esvaziar o carrinho.')
    } finally {
      setClearingCart(false)
    }
  }

  return (
    <main className="page section">
      <header className="section-header">
        <Link className="back-link" to={restaurant ? `/restaurantes/${restaurant.id}` : '/'}>
          Voltar
        </Link>
        <h1>{product.name}</h1>
        <p>{product.description}</p>
      </header>

      <section className="menu-editor-card product-detail-card">
        <h2>Detalhes do produto</h2>
        {product.imageUrl ? (
          <img className="product-hero-image" src={product.imageUrl} alt={product.name} />
        ) : (
          <div className="product-hero-placeholder">Sem imagem cadastrada</div>
        )}
      </section>

      <section className="stats-grid">
        <article className="stat-card">
          <strong>R$ {Number(product.promotionalPrice ?? product.price ?? 0).toFixed(2)}</strong>
          <span>Preco</span>
        </article>
        <article className="stat-card">
          <strong>{product.isAvailable ? 'Disponivel' : 'Indisponivel'}</strong>
          <span>Status</span>
        </article>
        <article className="stat-card">
          <strong>{restaurant?.name || 'Restaurante'}</strong>
          <span>Origem</span>
        </article>
      </section>

      <section className="menu-editor-card cart-action-card">
        <h2>Adicionar ao carrinho</h2>
        <div className="cart-form-grid">
          <label htmlFor="quantity">Quantidade</label>
          <input
            id="quantity"
            type="number"
            min="1"
            step="1"
            value={quantity}
            onChange={(event) => setQuantity(Math.max(1, Number(event.target.value) || 1))}
          />

          <label htmlFor="comment">Comentario para o pedido</label>
          <textarea
            id="comment"
            rows="3"
            value={comment}
            onChange={(event) => setComment(event.target.value)}
            placeholder="Ex.: sem cebola, molho a parte..."
          />

          <button type="button" className="submit-btn" onClick={handleAddToCart} disabled={adding}>
            {adding ? 'Adicionando...' : 'Adicionar ao carrinho'}
          </button>

          {cartMessage && <p className="form-feedback">{cartMessage}</p>}
          {showClearCartPrompt && (
            <div className="cart-conflict-box">
              <p>Seu carrinho tem itens de outro restaurante. Deseja esvaziar o carrinho e adicionar este produto?</p>
              <div className="cart-conflict-actions">
                <button type="button" className="submit-btn" onClick={handleClearCartAndAdd} disabled={clearingCart}>
                  {clearingCart ? 'Esvaziando...' : 'Esvaziar e adicionar'}
                </button>
                <button type="button" className="text-btn" onClick={() => setShowClearCartPrompt(false)} disabled={clearingCart}>
                  Manter carrinho atual
                </button>
              </div>
            </div>
          )}
        </div>
      </section>
    </main>
  )
}

function LoginPage() {
  const navigate = useNavigate()
  const [mode, setMode] = useState('login')
  const [accountType, setAccountType] = useState('Cliente')
  const [displayName, setDisplayName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')
  const accountTypes = ['Cliente', 'Entregador', 'Restaurante']

  async function handleSubmit(event) {
    event.preventDefault()
    setError('')
    setSuccess('')
    setLoading(true)
    if (mode === 'register' && !displayName.trim()) {
      setLoading(false)
      setError('Informe o nome para criar esta conta.')
      return
    }

    const endpoint = mode === 'login' ? '/api/auth/login' : '/api/auth/register'
    const payload = mode === 'login' ? { email, password } : { name: displayName.trim(), email, password, role: labelToRole(accountType) }

    try {
      const { response, data } = await apiJson(endpoint, {
        method: 'POST',
        body: JSON.stringify(payload),
      })
      if (!response.ok) throw new Error(data?.error ?? 'Falha na autenticacao.')

      storeAuthSession(data, mode === 'register' ? labelToRole(accountType) : 'Customer')
      if (mode === 'register') {
        localStorage.setItem('accountType', accountType)
        localStorage.setItem('displayName', displayName.trim())
        if (accountType === 'Restaurante') localStorage.setItem('restaurantName', displayName.trim())
        setSuccess('Conta criada com sucesso. Voce ja esta autenticado.')
      }
      const role = localStorage.getItem('role') || 'Customer'
      navigate(routeByRole(role))
    } catch (submitError) {
      setError(submitError.message || 'Nao foi possivel concluir a operacao.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <main className="page section">
      <section className="login-container">
        <header className="login-header">
          <Link className="back-link" to="/">Voltar ao inicio</Link>
          <h1>{mode === 'login' ? 'Entrar na conta' : 'Criar conta'}</h1>
          <p>Selecione o tipo de conta e informe suas credenciais.</p>
        </header>

        <form className="login-form" onSubmit={handleSubmit}>
          {mode === 'register' && (
            <>
              <label htmlFor="accountType">Tipo de conta</label>
              <select id="accountType" value={accountType} onChange={(event) => setAccountType(event.target.value)}>
                {accountTypes.map((type) => <option key={type} value={type}>{type}</option>)}
              </select>
            </>
          )}

          {mode === 'register' && (
            <>
              <label htmlFor="displayName">Nome</label>
              <input id="displayName" type="text" placeholder="Ex.: Joao Silva / Sabor da Vila" value={displayName} onChange={(event) => setDisplayName(event.target.value)} required />
            </>
          )}

          <label htmlFor="email">E-mail</label>
          <input id="email" type="email" placeholder="seuemail@dominio.com" value={email} onChange={(event) => setEmail(event.target.value)} required />

          <label htmlFor="password">Senha</label>
          <input id="password" type="password" placeholder="Digite sua senha" value={password} onChange={(event) => setPassword(event.target.value)} minLength={6} required />

          <button type="submit" className="submit-btn" disabled={loading}>{loading ? 'Processando...' : mode === 'login' ? 'Entrar' : 'Criar conta'}</button>

          {error && <p className="form-feedback error">{error}</p>}
          {success && <p className="form-feedback success">{success}</p>}

          <button type="button" className="text-btn" onClick={() => setMode((current) => (current === 'login' ? 'register' : 'login'))}>
            {mode === 'login' ? 'Nao tem conta? Criar conta' : 'Ja tem conta? Entrar'}
          </button>
        </form>
      </section>
    </main>
  )
}

function Shell({ title, subtitle, stats, actions = null }) {
  return (
    <main className="page section">
      <header className="section-header">
        <Link className="back-link" to="/">Voltar ao inicio</Link>
        <h1>{title}</h1>
        <p>{subtitle}</p>
      </header>

      <section className="stats-grid">
        {stats.map((stat) => (
          <article className="stat-card" key={stat.label}><strong>{stat.value}</strong><span>{stat.label}</span></article>
        ))}
      </section>

      {actions && <section className="dashboard-actions">{actions}</section>}
    </main>
  )
}

function CustomerPage() {
  const [orders, setOrders] = useState([])
  const [loadingOrders, setLoadingOrders] = useState(true)
  const [error, setError] = useState('')

  async function loadOrders() {
    setLoadingOrders(true)
    setError('')
    try {
      const { response, data } = await apiJson('/api/orders', {}, [])
      if (!response.ok) throw new Error(data?.error || 'Nao foi possivel carregar seus pedidos.')
      setOrders(Array.isArray(data) ? data : [])
    } catch (loadError) {
      setError(loadError.message || 'Falha ao carregar pedidos.')
    } finally {
      setLoadingOrders(false)
    }
  }

  useEffect(() => {
    loadOrders()
    window.addEventListener('orders:updated', loadOrders)
    return () => window.removeEventListener('orders:updated', loadOrders)
  }, [])

  const activeOrders = orders.filter((order) => !['Completed', 'Cancelled'].includes(String(order.status))).length
  const totalSpent = orders.reduce((sum, order) => sum + Number(order.total ?? 0), 0)

  return (
    <main className="page section">
      <header className="section-header">
        <Link className="back-link" to="/">Voltar ao inicio</Link>
        <h1>Meus pedidos</h1>
        <p>Acompanhe os pedidos criados pela sua conta.</p>
      </header>

      <section className="stats-grid">
        <article className="stat-card"><strong>{orders.length}</strong><span>Pedidos realizados</span></article>
        <article className="stat-card"><strong>{activeOrders}</strong><span>Pedidos em andamento</span></article>
        <article className="stat-card"><strong>{formatCurrency(totalSpent)}</strong><span>Total comprado</span></article>
      </section>

      <section className="menu-editor-card customer-orders-card">
        <div className="product-item-head">
          <h2>Historico de pedidos</h2>
          <button type="button" className="tiny-btn" onClick={loadOrders} disabled={loadingOrders}>
            {loadingOrders ? 'Atualizando...' : 'Atualizar'}
          </button>
        </div>

        {error && <p className="form-feedback error">{error}</p>}
        {loadingOrders ? (
          <p className="empty-products">Carregando pedidos...</p>
        ) : orders.length === 0 ? (
          <p className="empty-products">Nenhum pedido criado ainda.</p>
        ) : (
          <div className="customer-orders-list">
            {orders.map((order) => (
              <article className="customer-order-item" key={order.id}>
                  <div>
                    <strong>Pedido #{String(order.id).slice(0, 8)} - {order.restaurantName || order.RestaurantName || 'Restaurante'}</strong>
                    <span>Status: {orderStatusLabel(order.status)}</span>
                  </div>
                <strong>{formatCurrency(order.total)}</strong>
              </article>
            ))}
          </div>
        )}
      </section>
    </main>
  )
}

function DriverPage() {
  const [deliveries, setDeliveries] = useState([])
  const [loadingDeliveries, setLoadingDeliveries] = useState(true)
  const [updatingDeliveryId, setUpdatingDeliveryId] = useState(null)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  async function loadDeliveries() {
    setLoadingDeliveries(true)
    setError('')
    try {
      const { response, data } = await apiJson('/api/deliveries/me', {}, [])
      if (!response.ok) throw new Error(data?.error || 'Nao foi possivel carregar suas entregas.')
      setDeliveries(Array.isArray(data) ? data : [])
    } catch (loadError) {
      setError(loadError.message || 'Falha ao carregar entregas.')
    } finally {
      setLoadingDeliveries(false)
    }
  }

  async function updateDeliveryStatus(deliveryId, status) {
    setUpdatingDeliveryId(deliveryId)
    setError('')
    setSuccess('')
    try {
      const { response, data } = await apiJson(`/api/deliveries/${deliveryId}/status`, {
        method: 'PATCH',
        body: JSON.stringify(status),
      })
      if (!response.ok) throw new Error(data?.error || 'Nao foi possivel atualizar a entrega.')
      setSuccess('Entrega atualizada com sucesso.')
      await loadDeliveries()
    } catch (updateError) {
      setError(updateError.message || 'Falha ao atualizar entrega.')
    } finally {
      setUpdatingDeliveryId(null)
    }
  }

  useEffect(() => {
    loadDeliveries()
  }, [])

  const pickedUp = deliveries.filter((delivery) => delivery.status === 2 || delivery.status === 'PickedUp').length

  return (
    <main className="page section">
      <header className="section-header">
        <Link className="back-link" to="/">Voltar ao inicio</Link>
        <h1>Pagina do Entregador</h1>
        <p>Painel para acompanhar entregas atribuidas.</p>
      </header>

      <section className="stats-grid">
        <article className="stat-card"><strong>{deliveries.length}</strong><span>Entregas atribuidas</span></article>
        <article className="stat-card"><strong>{pickedUp}</strong><span>Coletas em rota</span></article>
        <article className="stat-card"><strong>3</strong><span>Limite simultaneo</span></article>
      </section>

      <section className="menu-editor-card customer-orders-card">
        <div className="product-item-head">
          <h2>Minhas entregas</h2>
          <button type="button" className="primary-action-btn dashboard-refresh-btn" onClick={loadDeliveries} disabled={loadingDeliveries}>
            {loadingDeliveries ? 'Atualizando...' : 'Atualizar'}
          </button>
        </div>
        {error && <p className="form-feedback error">{error}</p>}
        {success && <p className="form-feedback success">{success}</p>}
        {loadingDeliveries ? (
          <p className="empty-products">Carregando entregas...</p>
        ) : deliveries.length === 0 ? (
          <p className="empty-products">Nenhuma entrega atribuida agora.</p>
        ) : (
          <div className="customer-orders-list">
            {deliveries.map((delivery) => {
              const nextStatus = nextDeliveryStatus(delivery.status)
              return (
                <article className="customer-order-item" key={delivery.id}>
                  <div>
                    <strong>Entrega #{String(delivery.id).slice(0, 8)} - {delivery.restaurantName || delivery.RestaurantName || 'Restaurante'}</strong>
                    <span>Status: {deliveryStatusLabel(delivery.status)}</span>
                    <span>{delivery.addressSnapshot || 'Endereco nao informado'}</span>
                  </div>
                  {nextStatus && (
                    <button type="button" className="primary-action-btn driver-action-btn" onClick={() => updateDeliveryStatus(delivery.id, nextStatus.value)} disabled={updatingDeliveryId === delivery.id}>
                      {updatingDeliveryId === delivery.id ? 'Atualizando...' : nextStatus.label}
                    </button>
                  )}
                </article>
              )
            })}
          </div>
        )}
      </section>
    </main>
  )
}

function RestaurantPage() {
  const [restaurant, setRestaurant] = useState(null)
  const [orders, setOrders] = useState([])
  const [products, setProducts] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [expandedOrderId, setExpandedOrderId] = useState(null)
  const [orderDetails, setOrderDetails] = useState({})
  const [loadingOrderId, setLoadingOrderId] = useState(null)
  const [profileImageUrl, setProfileImageUrl] = useState('')
  const [savingProfileImage, setSavingProfileImage] = useState(false)
  const [profileImageMessage, setProfileImageMessage] = useState('')
  const token = getAccessToken()
  const userEmail = token ? resolveEmailFromToken(token) : null
  const tokenRestaurantId = token ? resolveRestaurantIdFromToken(token) : null

  async function loadRestaurantDashboard() {
    setLoading(true)
    setError('')
    try {
      await ensureAccessToken()
      const currentToken = getAccessToken()
      const currentUserEmail = currentToken ? resolveEmailFromToken(currentToken) : null
      const currentRestaurantId = currentToken ? resolveRestaurantIdFromToken(currentToken) : null
      const restaurantsResponse = await apiFetch('/api/restaurants')
      if (!restaurantsResponse.ok) throw new Error('Nao foi possivel identificar o restaurante.')
      const restaurantsData = await readJsonSafe(restaurantsResponse, [])
      const restaurants = Array.isArray(restaurantsData) ? restaurantsData : []
      const found = currentRestaurantId
        ? restaurants.find((item) => item?.id === currentRestaurantId)
        : restaurants.find((item) => (item?.email || '').trim().toLowerCase() === (currentUserEmail || '').trim().toLowerCase())
      if (!found?.id) throw new Error('Restaurante vinculado ao usuario nao encontrado.')

      setRestaurant(found)
      setProfileImageUrl(found.profileImageUrl || '')
      localStorage.setItem('restaurantId', found.id)
      localStorage.setItem('restaurantName', found.name || 'Restaurante')

      const [ordersResponse, productsResponse] = await Promise.all([
        apiFetch(`/api/orders/restaurant/${found.id}`),
        apiFetch(`/api/restaurants/${found.id}/products`),
      ])
      const [ordersData, productsData] = await Promise.all([
        readJsonSafe(ordersResponse, []),
        readJsonSafe(productsResponse, []),
      ])
      if (!ordersResponse.ok) throw new Error(ordersData?.error || 'Nao foi possivel carregar pedidos do restaurante.')
      if (!productsResponse.ok) throw new Error(productsData?.error || 'Nao foi possivel carregar produtos do restaurante.')

      setOrders(Array.isArray(ordersData) ? ordersData : [])
      setProducts(Array.isArray(productsData) ? productsData : [])
    } catch (loadError) {
      setError(loadError.message || 'Falha ao carregar dashboard do restaurante.')
    } finally {
      setLoading(false)
    }
  }
  useEffect(() => {
    loadRestaurantDashboard()
  }, [])

  const restaurantName = restaurant?.name || localStorage.getItem('restaurantName') || 'Restaurante'
  const newOrders = orders.filter((order) => String(order.status) === 'Created' || Number(order.status) === 0).length
  const activeOrders = orders.filter((order) => !['Completed', 'Cancelled'].includes(String(order.status)) && ![4, 5].includes(Number(order.status))).length
  const revenue = orders.reduce((sum, order) => sum + Number(order.total ?? 0), 0)

  async function handleSaveProfileImage(event) {
    event.preventDefault()
    if (!restaurant?.id) return
    setSavingProfileImage(true)
    setProfileImageMessage('')
    try {
      const payload = {
        name: restaurant.name,
        description: restaurant.description,
        cnpj: restaurant.cnpj,
        phone: restaurant.phone,
        email: restaurant.email,
        categoryId: restaurant.categoryId,
        profileImageUrl: profileImageUrl.trim() || null,
      }
      const { response, data } = await apiJson(`/api/restaurants/${restaurant.id}`, {
        method: 'PUT',
        body: JSON.stringify(payload),
      }, null)
      if (!response.ok) throw new Error(data?.error || 'Nao foi possivel salvar a foto do restaurante.')
      setRestaurant((current) => current ? { ...current, profileImageUrl: payload.profileImageUrl } : current)
      setProfileImageMessage('Foto do restaurante atualizada.')
    } catch (saveError) {
      setProfileImageMessage(saveError.message || 'Falha ao salvar foto do restaurante.')
    } finally {
      setSavingProfileImage(false)
    }
  }

  async function toggleOrderDetails(orderId) {
    if (expandedOrderId === orderId) {
      setExpandedOrderId(null)
      return
    }
    setExpandedOrderId(orderId)
    if (orderDetails[orderId] || !restaurant?.id) return

    setLoadingOrderId(orderId)
    try {
      const { response, data } = await apiJson(`/api/orders/restaurant/${restaurant.id}/${orderId}`, {}, null)
      if (!response.ok) throw new Error(data?.error || 'Nao foi possivel carregar detalhes do pedido.')
      setOrderDetails((current) => ({ ...current, [orderId]: data }))
    } catch (detailError) {
      setOrderDetails((current) => ({ ...current, [orderId]: { error: detailError.message || 'Falha ao carregar detalhes.' } }))
    } finally {
      setLoadingOrderId(null)
    }
  }

  return (
    <Shell
      title={`${restaurantName} Dashboard`}
      subtitle={loading ? 'Carregando operacao do restaurante...' : error || 'Visao da operacao para gestao de pedidos e cardapio.'}
      stats={[
        { label: 'Pedidos novos', value: String(newOrders) },
        { label: 'Pedidos em andamento', value: String(activeOrders) },
        { label: 'Itens no cardapio', value: String(products.length) },
        { label: 'Receita em pedidos', value: formatCurrency(revenue) },
      ]}
      actions={(
        <>
          <section className="restaurant-profile-editor menu-editor-card">
            <div className="restaurant-profile-photo large">{restaurant?.profileImageUrl ? <img src={restaurant.profileImageUrl} alt={restaurantName} /> : <span>{restaurantName.slice(0, 1)}</span>}</div>
            <form className="restaurant-profile-form" onSubmit={handleSaveProfileImage}>
              <label htmlFor="restaurantProfileImageUrl">Foto de perfil do restaurante</label>
              <div className="restaurant-profile-input-row">
                <input id="restaurantProfileImageUrl" type="text" inputMode="url" placeholder="/uploads/restaurants/logo.png ou https://..." value={profileImageUrl} onChange={(event) => setProfileImageUrl(event.target.value)} />
                <button type="submit" className="primary-action-btn" disabled={savingProfileImage || loading}>{savingProfileImage ? 'Salvando...' : 'Salvar foto'}</button>
              </div>
              {profileImageMessage && <p className="form-feedback">{profileImageMessage}</p>}
            </form>
          </section>
          <Link to="/restaurante/cardapio" className="primary-action-btn">Editar cardapio</Link>
          <button type="button" className="primary-action-btn dashboard-refresh-btn" onClick={loadRestaurantDashboard} disabled={loading}>
            {loading ? 'Atualizando...' : 'Atualizar pedidos'}
          </button>
          <section className="restaurant-orders-preview">
            <h2>Pedidos recentes</h2>
            {orders.length === 0 ? (
              <p className="empty-products">Nenhum pedido recebido ainda.</p>
            ) : (
              <div className="customer-orders-list">
                {orders.slice(0, 5).map((order) => (
                  <article className="customer-order-item restaurant-order-item" key={order.id}>
                    <button type="button" className="restaurant-order-summary" onClick={() => toggleOrderDetails(order.id)}>
                      <div>
                        <strong>Pedido #{String(order.id).slice(0, 8)}</strong>
                        <span>Status: {orderStatusLabel(order.status)}</span>
                      </div>
                      <strong>{formatCurrency(order.total)}</strong>
                    </button>
                    {expandedOrderId === order.id && (
                      <div className="restaurant-order-details">
                        {loadingOrderId === order.id ? (
                          <p className="empty-products">Carregando detalhes...</p>
                        ) : orderDetails[order.id]?.error ? (
                          <p className="form-feedback error">{orderDetails[order.id].error}</p>
                        ) : (
                          <>
                            <div className="order-values-grid">
                              <span>Subtotal: {formatCurrency(orderDetails[order.id]?.order?.subtotal ?? order.subtotal)}</span>
                              <span>Entrega: {formatCurrency(orderDetails[order.id]?.order?.deliveryFee ?? order.deliveryFee)}</span>
                              <span>Desconto: {formatCurrency(orderDetails[order.id]?.order?.discount ?? order.discount)}</span>
                            </div>
                            <div className="order-items-list">
                              {(orderDetails[order.id]?.items || []).map((item) => (
                                <div className="order-detail-item" key={item.id}>
                                  <div>
                                    <strong>{item.quantity}x {item.productName}</strong>
                                    {item.observation && <span>Comentario: {item.observation}</span>}
                                  </div>
                                  <strong>{formatCurrency(item.totalPrice)}</strong>
                                </div>
                              ))}
                            </div>
                          </>
                        )}
                      </div>
                    )}
                  </article>
                ))}
              </div>
            )}
          </section>
        </>
      )}
    />
  )
}

function RestaurantMenuPage() {
  const [restaurantId, setRestaurantId] = useState(localStorage.getItem('restaurantId') || '')
  const [menuCategoryId, setMenuCategoryId] = useState('')
  const [menuCategories, setMenuCategories] = useState([])
  const [name, setName] = useState('')
  const [description, setDescription] = useState('')
  const [price, setPrice] = useState('')
  const [promotionalPrice, setPromotionalPrice] = useState('')
  const [isAvailable, setIsAvailable] = useState(true)
  const [imageUrl, setImageUrl] = useState('')
  const [editingProductId, setEditingProductId] = useState(null)
  const [products, setProducts] = useState([])
  const [loadingProducts, setLoadingProducts] = useState(false)
  const [loadingCategories, setLoadingCategories] = useState(false)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  const token = getAccessToken()
  const userEmail = token ? resolveEmailFromToken(token) : null
  const tokenRestaurantId = token ? resolveRestaurantIdFromToken(token) : null

  async function resolveRestaurantIdFromLoggedUser() {
    await ensureAccessToken()
    const currentToken = getAccessToken()
    const currentUserEmail = currentToken ? resolveEmailFromToken(currentToken) : null
    const currentRestaurantId = currentToken ? resolveRestaurantIdFromToken(currentToken) : null
    if (!currentToken) return
    if (currentRestaurantId) {
      setRestaurantId(currentRestaurantId)
      localStorage.setItem('restaurantId', currentRestaurantId)
      return
    }
    if (!currentUserEmail) return
    try {
      const response = await apiFetch('/api/restaurants')
      if (!response.ok) return
      const data = await readJsonSafe(response, [])
      const found = (Array.isArray(data) ? data : []).find((item) => (item?.email || '').trim().toLowerCase() === currentUserEmail.trim().toLowerCase())
      if (found?.id) {
        setRestaurantId(found.id)
        localStorage.setItem('restaurantId', found.id)
      }
    } catch {
      // noop
    }
  }
  async function loadProducts(targetRestaurantId = restaurantId) {
    if (!targetRestaurantId) return
    setLoadingProducts(true)
    setError('')
    try {
      const response = await apiFetch(`/api/restaurants/${targetRestaurantId}/products`)
      if (!response.ok) throw new Error('Falha ao buscar produtos do restaurante.')
      const data = await readJsonSafe(response, [])
      setProducts(Array.isArray(data) ? data : [])
      localStorage.setItem('restaurantId', targetRestaurantId)
    } catch (loadError) {
      setError(loadError.message || 'Nao foi possivel carregar os produtos.')
    } finally {
      setLoadingProducts(false)
    }
  }

  async function loadMenuCategories() {
    setLoadingCategories(true)
    setError('')
    try {
      const response = await apiFetch('/api/menu-categories')
      if (!response.ok) throw new Error('Falha ao buscar categorias do cardapio.')
      const data = await readJsonSafe(response, [])
      const categoriesList = Array.isArray(data) ? data : []
      setMenuCategories(categoriesList)
      if (categoriesList.length > 0) setMenuCategoryId((current) => current || categoriesList[0].id)
    } catch (loadError) {
      setError(loadError.message || 'Nao foi possivel carregar as categorias.')
    } finally {
      setLoadingCategories(false)
    }
  }

  useEffect(() => {
    if (!restaurantId) {
      resolveRestaurantIdFromLoggedUser()
      loadMenuCategories()
      return
    }
    loadProducts(restaurantId)
    loadMenuCategories()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  useEffect(() => {
    if (restaurantId) {
      loadProducts(restaurantId)
      loadMenuCategories()
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [restaurantId])

  async function handleCreateProduct(event) {
    event.preventDefault()
    setError('')
    setSuccess('')
    if (!restaurantId.trim()) return setError('Informe o ID do restaurante.')
    if (!menuCategoryId.trim()) return setError('Selecione uma categoria de cardapio antes de cadastrar o produto.')

    setSaving(true)
    try {
      const payload = {
        menuCategoryId: menuCategoryId.trim(),
        name: name.trim(),
        description: description.trim(),
        price: Number(price),
        promotionalPrice: promotionalPrice ? Number(promotionalPrice) : null,
        isAvailable,
        imageUrl: imageUrl.trim() || null,
      }
      const isEditing = Boolean(editingProductId)
      const endpoint = isEditing ? `/api/products/${editingProductId}` : `/api/restaurants/${restaurantId}/products`
      const method = isEditing ? 'PUT' : 'POST'
      const { response, data } = await apiJson(endpoint, {
        method,
        body: JSON.stringify(payload),
      })
      if (!response.ok) throw new Error(data?.error || (isEditing ? 'Falha ao editar produto.' : 'Falha ao cadastrar produto.'))

      setSuccess(isEditing ? 'Produto atualizado com sucesso.' : 'Produto cadastrado com sucesso.')
      setName('')
      setDescription('')
      setPrice('')
      setPromotionalPrice('')
      setImageUrl('')
      setIsAvailable(true)
      setEditingProductId(null)
      await loadProducts(restaurantId)
    } catch (saveError) {
      setError(saveError.message || 'Nao foi possivel cadastrar o produto.')
    } finally {
      setSaving(false)
    }
  }

  function handleEditProduct(product) {
    setEditingProductId(product.id)
    setName(product.name || '')
    setDescription(product.description || '')
    setPrice(String(product.price ?? ''))
    setPromotionalPrice(product.promotionalPrice === null || product.promotionalPrice === undefined ? '' : String(product.promotionalPrice))
    setIsAvailable(Boolean(product.isAvailable))
    setImageUrl(product.imageUrl || '')
    if (product.menuCategoryId) setMenuCategoryId(product.menuCategoryId)
    setSuccess('')
    setError('')
  }

  function handleCancelEdit() {
    setEditingProductId(null)
    setName('')
    setDescription('')
    setPrice('')
    setPromotionalPrice('')
    setImageUrl('')
    setIsAvailable(true)
    setSuccess('')
    setError('')
  }

  return (
    <main className="page section">
      <header className="section-header">
        <Link className="back-link" to="/restaurante">Voltar ao dashboard</Link>
        <h1>Editar cardapio</h1>
        <p>Cadastre produtos e visualize os itens ja cadastrados no restaurante.</p>
      </header>

      <section className="menu-editor-grid">
        <article className="menu-editor-card">
          <h2>Cadastro de produto</h2>
          <form className="login-form" onSubmit={handleCreateProduct}>
            {restaurantId && <p className="form-feedback success">Restaurante identificado automaticamente.</p>}

            <label htmlFor="menuCategoryId">Categoria do cardapio</label>
            <select id="menuCategoryId" value={menuCategoryId} onChange={(event) => setMenuCategoryId(event.target.value)} required disabled={loadingCategories || menuCategories.length === 0}>
              {menuCategories.length === 0 ? <option value="">{loadingCategories ? 'Carregando categorias...' : 'Nenhuma categoria cadastrada'}</option> : menuCategories.map((category) => <option key={category.id} value={category.id}>{category.name}</option>)}
            </select>

            <label htmlFor="productName">Nome</label>
            <input id="productName" type="text" value={name} onChange={(event) => setName(event.target.value)} required />

            <label htmlFor="productDescription">Descricao</label>
            <input id="productDescription" type="text" value={description} onChange={(event) => setDescription(event.target.value)} required />

            <label htmlFor="productPrice">Preco</label>
            <input id="productPrice" type="number" min="0.01" step="0.01" value={price} onChange={(event) => setPrice(event.target.value)} required />

            <label htmlFor="promotionalPrice">Preco promocional (opcional)</label>
            <input id="promotionalPrice" type="number" min="0.01" step="0.01" value={promotionalPrice} onChange={(event) => setPromotionalPrice(event.target.value)} />

            <label htmlFor="imageUrl">Imagem (URL ou caminho /uploads)</label>
            <input id="imageUrl" type="text" inputMode="url" placeholder="/uploads/products/burger.png ou https://..." value={imageUrl} onChange={(event) => setImageUrl(event.target.value)} />

            <label className="inline-check"><input type="checkbox" checked={isAvailable} onChange={(event) => setIsAvailable(event.target.checked)} />Disponivel</label>

            <button type="submit" className="submit-btn" disabled={saving}>{saving ? 'Salvando...' : editingProductId ? 'Salvar edicao' : 'Cadastrar produto'}</button>
            {editingProductId && <button type="button" className="text-btn" onClick={handleCancelEdit}>Cancelar edicao</button>}
            <button type="button" className="text-btn" onClick={() => { loadProducts(restaurantId); loadMenuCategories() }} disabled={loadingProducts || !restaurantId}>{loadingProducts ? 'Carregando produtos...' : 'Atualizar lista de produtos'}</button>

            {error && <p className="form-feedback error">{error}</p>}
            {success && <p className="form-feedback success">{success}</p>}
          </form>
        </article>

        <article className="menu-editor-card">
          <h2>Produtos cadastrados</h2>
          {products.length === 0 ? (
            <p className="empty-products">Nenhum produto encontrado para este restaurante.</p>
          ) : (
            <div className="product-list">
              {products.map((product) => (
                <div className="product-item" key={product.id}>
                  <div className="product-item-head">
                    <strong>{product.name}</strong>
                    <button type="button" className="tiny-btn" onClick={() => handleEditProduct(product)}>Editar</button>
                  </div>
                  <span>{product.description}</span>
                  <small>Preco: R$ {Number(product.price || 0).toFixed(2)} | Disponivel: {product.isAvailable ? 'Sim' : 'Nao'}</small>
                </div>
              ))}
            </div>
          )}
        </article>
      </section>
    </main>
  )
}

function App() {
  return (
    <>
      <Routes>
        <Route path="/" element={<MainPage />} />
        <Route path="/restaurantes/:id" element={<RestaurantPublicPage />} />
        <Route path="/produtos/:id" element={<ProductPublicPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/cliente" element={<CustomerPage />} />
        <Route path="/entregador" element={<DriverPage />} />
        <Route path="/restaurante" element={<RestaurantPage />} />
        <Route path="/restaurante/cardapio" element={<RestaurantMenuPage />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
      <GlobalCart />
    </>
  )
}

export default App









