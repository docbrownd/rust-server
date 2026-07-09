use stubs::land::v0::land_service_server::LandService;
use stubs::*;
use tonic::{Request, Response, Status};

use super::MissionRpc;

#[tonic::async_trait]
impl LandService for MissionRpc {
    async fn find_path_on_roads(
        &self,
        request: Request<land::v0::FindPathOnRoadsRequest>,
    ) -> Result<Response<land::v0::FindPathOnRoadsResponse>, Status> {
        let res = self.request("findPathOnRoads", request).await?;
        Ok(Response::new(res))
    }

    async fn get_closest_point_on_roads(
        &self,
        request: Request<land::v0::GetClosestPointOnRoadsRequest>,
    ) -> Result<Response<land::v0::GetClosestPointOnRoadsResponse>, Status> {
        let res = self.request("getClosestPointOnRoads", request).await?;
        Ok(Response::new(res))
    }
}
