package cangjie
import std.fs.*

main(): Int64 {
    // init mock data
    mockDataInit()

    // ensure data and upload dirs exist
    let dataPath = Path(DATA_DIR)
    if (!exists(dataPath)) {
        Directory.create(dataPath)
    }
    let uploadPath = Path(UPLOAD_DIR)
    if (!exists(uploadPath)) {
        Directory.create(uploadPath,
            recursive: false)
    }

    let server = HttpServer()

    // auth routes
    server.post("/api/auth/register",
        { req => handleRegister(req) })
    server.post("/api/auth/login",
        { req => handleLogin(req) })

    // user routes
    server.get("/api/users/me",
        { req => handleGetMe(req) })
    server.put("/api/users/me",
        { req => handleUpdateMe(req) })

    // category routes
    server.get("/api/categories",
        { req =>
            handleListCategories(req) })

    // post routes — static paths
    server.post("/api/posts",
        { req => handleCreatePost(req) })
    server.get("/api/posts",
        { req => handleListPosts(req) })
    server.get("/api/posts/me",
        { req => handleMyPosts(req) })

    // post routes — parameterized :id
    server.addParam("GET",
        "/api/posts/:id",
        { req => handleGetPost(req) })
    server.addParam("PUT",
        "/api/posts/:id",
        { req => handleUpdatePost(req) })
    server.addParam("DELETE",
        "/api/posts/:id",
        { req => handleDeletePost(req) })

    // favorite routes
    server.addParam("POST",
        "/api/posts/:id/favorite",
        { req => handleAddFav(req) })
    server.addParam("DELETE",
        "/api/posts/:id/favorite",
        { req => handleRemoveFav(req) })
    server.get("/api/users/me/favorites",
        { req => handleListFavs(req) })

    // image upload
    server.post("/api/images/upload",
        { req => handleUpload(req) })

    println("Server starting on port " +
        SERVER_PORT.toString())
    server.start(SERVER_PORT)
    return 0
}
